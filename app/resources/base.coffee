'use strict'
pi = require '../core'
utils = pi.utils

pi.resources = {}

#shortcut
pi.export(pi.resources,"$r")

_singular = (str) ->
  str.replace /s$/,''

# Resources used to share and synchronize data between views.
# All resources should have 'id' field in order to access them by id and to cache resources locally. 

class pi.resources.Base extends pi.EventDispatcher
  # initialize resource with name
  @set_resource: (plural, singular) ->
    # element by id
    @__all_by_id__ = {}
    # temp elements by temp id
    @__all_by_tid__ = {}
    @__all__ = []
    @resources_name = plural
    @resource_name = singular || _singular(plural)

  # fill resources with data

  @load: (data,silent=false) ->
    if data?
      elements = (@build(el,true) for el in data)
      @trigger('load',{}) unless silent
      elements

  @clear_all: ->
    el.dispose() for el in @__all__
    @__all_by_id__ = {}
    @__all_by_tid__ = {}
    @__all__.length = 0

  # return resource by id
  @get: (id) ->
    @__all_by_id__[id] || @__all_by_tid__[id]

  @add: (el) ->
    return if @get(el.id)
    if el.__temp__ is true
      @__all_by_tid__[el.id] = el
    else
      @__all_by_id__[el.id] = el
    @__all__.push el

  # create new resource
  @build: (data={}, silent = false, add = true) ->
    unless (data.id && (el = @get(data.id)))
      # create element with temp id
      unless data.id
        data.id = "tid_#{utils.uid()}"
        data.__temp__ = true
      
      el = new @(data)
      if add
        @add el  
        # resource should not trigger 'create' event if element is temporary
        @trigger('create', @_wrap(el)) unless (silent or el.__temp__) 
      el
    else
      el.set(data)

  @created: (el, temp_id) ->
    if @__all_by_tid__[temp_id]
      delete @__all_by_tid__[temp_id]
      @__all_by_id__[el.id] = el

  @clear_temp: (silent = false) ->
    for own _, el of @__all_by_tid__
      @remove el, silent
    @__all_by_tid__ = {}

  @remove_by_id: (id, silent) ->
    el = @get(id)
    if el?
      @remove el
    return false

  @remove: (el, silent) ->
    if @__all_by_id__[el.id]?
      delete @__all_by_id__[el.id]
    else
      delete @__all_by_tid__[el.id]
    
    @__all__.splice @__all__.indexOf(el), 1
    @trigger('destroy', @_wrap(el)) unless silent
    el.dispose()
    return true

  @listen: (callback, filter) ->
    pi.event.on "#{@resources_name}_update", callback, null, filter 

  @trigger: (event,data) ->
    data.type = event
    pi.event.trigger "#{@resources_name}_update", data, false

  @off: (callback) ->
    if callback?
      pi.event.off "#{@resources_name}_update", callback 
    else
      pi.event.off "#{@resources_name}_update" 

  @all: ->
    @__all__.slice()

  # use utils.object_ext to retrieve cached items 
  @where: (params) ->
    el for el in @__all__ when utils.matchers.object_ext(params)(el)

  @_wrap: (el) ->
    if el instanceof pi.resources.Base
      utils.wrap el.constructor.resource_name, el
    else
      el

  constructor: (data={}) ->
    super
    @_changes = {}
    @_persisted = true if (data.id? and not data.__temp__)
    @initialize data

  initialize: (data) ->
    return if @_initialized
    @set(data,true)
    @_initialized = true

  @register_callback 'initialize'

  created: (temp_id) ->
    @
    @constructor.created(@,temp_id)

  dispose: ->
    for own key,_ of @
      delete @[key]
    @disposed = true
    @

  @register_callback 'dispose', as: 'destroy'

  remove: (silent = false) ->
    @constructor.remove @, silent

  attributes: ->
    res = {}
    for key, change of @_changes
      res[key] = change.val
    res

  set: (params, silent) ->
    _changed = false
    _was_id = !!@id and !(@__temp__ is true)
    _old_id = @id
    for own key,val of params
      if @[key]!=val and not (typeof @[key] is 'function')
        _changed = true
        @_changes[key] = old_val: @[key], val: val
        @[key] = val
    
    if (@id|0) and not _was_id
      delete @__temp__
      @_persisted = true
      @__tid__ = _old_id 
      type = 'create'
      @created(_old_id)
    else
      type = 'update' 
    @trigger(type, (if type is 'create' then @ else @_changes)) if (_changed && !silent)
    @

  @register_callback 'set', as: 'update'

  trigger: (e, data, bubbles = false) ->
    super
    @constructor.trigger e, @constructor._wrap(@)