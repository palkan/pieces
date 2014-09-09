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
    @__all_by_id__ = {}
    @__all__ = []
    @resources_name = plural
    @resource_name = singular || _singular(plural)

  # fill resources with data

  @load: (data) ->
    if data?
      @build(el,true) for el in data

  @clear_all: ->
    el.dispose for el in @__all__
    @__all_by_id__ = {}
    @__all__.length = 0

  # return resource by id
  @get: (id) ->
    @__all_by_id__[id]

  @add: (el) ->
    @__all_by_id__[el.id] = el
    @__all__.push el

  # create new resource
  @build: (data={}, silent = false, add = true) ->
    unless (data.id && (el = @get(data.id)))
      el = new @(data)
  
      if el.id and add
        @add el  
        @trigger('create', @_wrap(el)) unless silent
      el
    else
      el.set(data)

  @remove_by_id: (id, silent) ->
    el = @get(id)
    if el?
      @remove el
    return false

  @remove: (el, silent) ->
    if @__all_by_id__[el.id]?
      @__all__.splice @__all__.indexOf(el), 1
      delete @__all_by_id__[el.id]
    @trigger('destroy', @_wrap(el)) unless silent
    el.dispose()
    return true

  @listen: (callback, filter) ->
    pi.event.on "#{@resources_name}_update", callback, null, filter 

  @trigger: (event,data) ->
    data.type = event
    pi.event.trigger "#{@resources_name}_update", data

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
      data = {}
      data[el.constructor.resource_name] = el
      data
    else
      el

  constructor: (data) ->
    super
    @_changes = {}
    @initialize data

  initialize: (data) ->
    return if @_initialized
    @set(data,true)
    @_initialized = true

  @register_callback 'initialize'

  dispose: ->
    for own key,_ of @
      delete @[key]
    @disposed = true
    @

  attributes: ->
    res = {}
    for key, change of @_changes
      res[key] = change.val
    res

  set: (params, silent) ->
    _changed = false
    for own key,val of params
      if @[key]!=val
        _changed = true
        @_changes[key] = old_val: @[key], val: val
        @[key] = val
    @trigger('update', @_changes) if (_changed && !silent)
    @

  trigger: (e, data, bubbles = true) ->
    super
    @constructor.trigger e, @constructor._wrap(@)