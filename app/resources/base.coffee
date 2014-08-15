do (context = this) ->
  "use strict"

  # shortcuts
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  pi.resources = {}

  #shortcut
  context.$r = pi.resources

  _singular = (str) ->
    str.replace /s$/,''

  _wrap = (el) ->
    if el instanceof pi.resources.Base
      data = {}
      data[el.constructor.resource_name] = el
      data
    else
      el

  # Resources used to share and synchronize data between views.
  # All resources should have 'id' field in order to access them by id and to cache resources locally. 
  
  class pi.resources.Base extends pi.Core
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
          @trigger('create', _wrap(el)) unless silent
        el
      else
        el.set(data)

    @remove_by_id: (id, silent) ->
      el = @get(id)
      if el?
        @remove el
      return false

    @remove: (el, silent) ->
      if el instanceof @
        if @__all_by_id__[el.id]?
          @__all__.splice @__all__.indexOf(el), 1
          delete @__all_by_id__[el.id]
        @trigger('destroy', _wrap(el)) unless silent
        el.dispose()
        return true
      return false

    @listen: (callback) ->
      pi.event.on "#{@resources_name}_update", callback 

    @trigger: (event,data) ->
      pi.event.trigger "#{@resources_name}_update", utils.merge(data,type: event)

    @off: (callback) ->
      if callback?
        pi.event.off "#{@resources_name}_update", callback 
      else
        pi.event.off "#{@resources_name}_update" 

    @all: ->
      @__all__.slice()

    constructor: (data) ->
      @set(data,true)

    dispose: ->
      for own key,_ of @
        delete @[key]
      @disposed = true
      @

    set: (params, silent) ->
      _changed = false
      for own key,val of params
        (_changed = true) if @[key]!=val
        @[key] = val
      @trigger('update') if (_changed && !silent)
      @

    trigger: (e) ->
      @constructor.trigger e, _wrap(@)