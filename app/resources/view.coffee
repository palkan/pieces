'use strict'
pi = require '../core'
require './base'
utils = pi.utils

class pi.resources.ViewItem extends pi.EventDispatcher
  constructor: (@view, data) ->
    super
    @_changes = {}
    @set(data,true)

  utils.extend @::, pi.resources.Base::, false

  trigger: (e,data,bubbles = true) ->
    super
    @view.trigger e, @view._wrap(@)


# Resource View is a temporary projection of resource
class pi.resources.View extends pi.EventDispatcher
  # generate new view for resource
  constructor: (@resources, scope) ->
    super
    @__all_by_id__ = {}
    @__all__ = []
    @resources_name = @resources.resources_name
    @resource_name = @resources.resource_name
    
    @_filter = if scope? then utils.matchers.object_ext(scope) else -> true

    @resources.listen (e) =>
      # handle only update and destroy events
      el = e.data[@resource_name]
      return unless @_filter(el)

      @["on_#{e.data.type}"]?(el)
  
  utils.extend @::, pi.resources.Base

  on_update: (el) ->
    if (view_item = @get(el.id))
      view_item.set(el.attributes())

  on_destroy: (el) ->
    if (view_item = @get(el.id))
      @remove view_item

  # create new resource
  build: (data={}, silent = false, add = true) ->
    unless (el = @get(data.id))
      data = data.attributes() if data instanceof pi.resources.Base
      el = new pi.resources.ViewItem(@,data)
      if el.id and add
        @add el  
        @trigger('create', @_wrap(el)) unless silent
      el
    else
      el.set(data)

  _wrap: (el) ->
    if el instanceof pi.resources.ViewItem
      data = {}
      data[el.view.resource_name] = el
      data
    else
      el

  listen: (callback) ->
    @on "update", callback

  trigger: (event,data) ->
    data.type = event
    super "update", data 