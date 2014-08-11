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
        @create(el,true) for el in data

    @delete_all: ->
      @__all_by_id__ = {}
      @__all__.length = 0

    # return resource by id
    @find: (id) ->
      @__all_by_id__[id]

    # create new resource
    @create: (data={}, silent) ->
      data.id ||= utils.uid()
      el = new @(data)
      @__all_by_id__[el.id] = el
      @__all__.push el
      @trigger('create', _wrap(el)) unless silent
      el

    @destroy: (id, silent) ->
      el = @find(id)
      if el?
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
      @update(data,true)

    destroy: ->
      @constructor.destroy @id

    dispose: ->
      for own key,_ of @
        delete @[key]
      @disposed = true

    update: (params, silent) ->
      for own key,val of params
        @[key] = val
      @trigger('update') unless silent

    trigger: (e) ->
      @constructor.trigger e, _wrap(@)