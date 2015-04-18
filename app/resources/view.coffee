'use strict'
EventDispatcher = require('../core/events').EventDispatcher
utils = require '../core/utils'
ResourceEvent = require './events'
Base = require './base'

class ViewItem extends EventDispatcher
  constructor: (@view, data, @options={}) ->
    super
    if @options.params? and @options.params.indexOf('id')<0
      @options.params.push 'id'
    @changes = {}
    @set(data,true)

  utils.extend @::, Base::, false

  created: (tid) ->
    @view.created(@,tid)

  trigger: (e,data,bubbles = true) ->
    super
    @view.trigger e, @view._wrap(@)

  attributes: ->
    if @options.params?
      data = utils.extract(@,@options.params)
      if @options.id_alias?
        data[@options.id_alias] = data.id if @options.id_alias
        delete data.id
      data
    else
      Base::attributes.call(@)

# Resource View is a temporary projection of resource
class View extends EventDispatcher
  # Generate new view for resource
  # Options:
  #   copy: if set to `true` then copies every item into `ViewItem`; otherwise collects references to items
  #   params: parameters filter for items
  #   id_alias: rename 'id' field when returning attributes; if set to `false` then remove attributes without id 
  constructor: (@resources, scope, @options={}) ->
    super
    @__all_by_id__ = {}
    @__all_by_tid__ = {}
    @__all__ = []
    @resources_name = @resources.resources_name
    @resource_name = @resources.resource_name
    
    @_filter = if (scope? and scope != false) then utils.matchers.object_ext(scope) else utils.truthy

    @resources.listen (e) =>
      el = e.data[@resource_name]
      if el?
        return unless @_filter(el)

      @["on_#{e.data.type}"]?(el)
  
  utils.extend @::, Base

  on_update: (el) ->
    if (view_item = @get(el.id))
      view_item.set(el.attributes())

  on_destroy: (el) ->
    if (view_item = @get(el.id))
      @remove view_item
 
  # if 'force' is true then destroy items even if they are not copied
  clear_all: (force = false)->
    unless (@options.copy is false) and (force is false)
      if force and !@options.copy
        @__all_by_id__ = {}
        @__all_by_tid__ = {}
        el.remove() for el in @__all__
      else
        el.dispose() for el in @__all__
    @__all_by_id__ = {}
    @__all_by_tid__ = {}
    @__all__.length = 0
  
  # create new resource
  build: (data={}, silent = false, params={}) ->
    unless (el = @get(data.id))
      if data instanceof Base and @options.copy is false
        el = data
      else
        if data instanceof Base
          data = data.attributes()
        utils.extend data, params, true
        el = new ViewItem(@,data,@options)
      if el.id
        @add el  
        @trigger(ResourceEvent.Create, @_wrap(el)) unless silent
      el
    else
      el.set(data, silent)

  _wrap: (el) ->
    if el instanceof ViewItem
      utils.obj.wrap el.view.resource_name, el
    else if el instanceof Base
      utils.obj.wrap el.constructor.resource_name, el
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

  off: (callback) ->
    super "update", callback

View.ViewItem = ViewItem

module.exports = View
