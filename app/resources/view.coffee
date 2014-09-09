'use strict'
pi = require '../core'
require './base'
utils = pi.utils

class pi.resources.ViewItem extends pi.EventDispatcher
  constructor: (@view, data, @options={}) ->
    super
    if @options.params? and @options.params.indexOf('id')<0
      @options.params.push 'id'
    @_changes = {}
    @set(data,true)

  utils.extend @::, pi.resources.Base::, false

  trigger: (e,data,bubbles = true) ->
    super
    @view.trigger e, @view._wrap(@)

  attributes: ->
    if @options.params?
      data = utils.extract({},@,@options.params)
      if @options.id_alias?
        data[@options.id_alias] = data.id if @options.id_alias
        delete data.id
        data
    else
      pi.resources.Base::attributes.call(@)

# Resource View is a temporary projection of resource
class pi.resources.View extends pi.EventDispatcher
  # generate new view for resource
  constructor: (@resources, scope, @options={}) ->
    super
    @__all_by_id__ = {}
    @__all__ = []
    @resources_name = @resources.resources_name
    @resource_name = @resources.resource_name
    
    @_filter = if (scope? and scope != false) then utils.matchers.object_ext(scope) else -> true

    @resources.listen (e) =>
      el = e.data[@resource_name]
      if el?
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
      if data instanceof pi.resources.Base and @options.copy is false
        el = data
      else
        if data instanceof pi.resources.Base
          data = data.attributes()
        el = new pi.resources.ViewItem(@,data,@options)
      if el.id and add
        @add el  
        @trigger('create', @_wrap(el)) unless silent
      el
    else
      el.set(data)

  _wrap: (el) ->
    if el instanceof pi.resources.ViewItem
      utils.wrap el.view.resource_name, el
    else if el instanceof pi.resources.Base
      utils.wrap el.constructor.resource_name, el
    else
      el

  serialize: ->
    res = []
    for el in @all()
      res.push el.attributes()
    res

  listen: (callback) ->
    @on "update", callback

  trigger: (event,data) ->
    data.type = event
    super "update", data 