'use strict'
pi = require '../../core'
require '../../plugins/plugin'
require '../../components/base/list'
utils = pi.utils

_where_rxp = /^(\w+)\.(where|find)\(([\w\s\,\:]+)\)(?:\.([\w]+))?$/i
_app_rxp = /^app\.([\.\w]+)\.(\w+)$/
# [Plugin]
#
# Bind resources to List (handle create, update and destroy events)  
class pi.List.Restful extends pi.Plugin
  id: 'restful'
  initialize: (@list) ->
    super
    @items_by_id = {}
    @listen_load = @list.options.listen_load is true
    @listen_create = if @list.options.listen_create? then @list.options.listen_create else @listen_load
    if (rest = @list.options.rest)? 
      if (matches = rest.match(_app_rxp))
        ref = utils.get_path(pi.app, matches[1])
        resources = ref[matches[2]]?() if ref? 
      else if (matches = rest.match(_where_rxp))
        rest = matches[1]
        ref = $r[utils.camelCase(rest)]
        if ref?
          if matches[2] is 'where'
            resources = ref
            @scope = {}
            for param in matches[3].split(/\s*\,\s*/)
              [key,val] = param.split /\s*\:\s*/
              @scope[key] = utils.serialize val
          else if matches[2] is 'find'
            el = ref.get(matches[3])
            if el? and typeof el[matches[4]] is 'function'
              resources = el[matches[4]]()
      else
        resources = $r[utils.camelCase(rest)]

    if resources?
      @bind resources, @list.options.load_rest, @scope

    @list.delegate_to @, 'find_by_id'
    
    @list.on 'destroyed', =>
      @bind null
      false
    @

  bind: (resources, load = false, params) ->
    if @resources
      @resources.off @resource_update()
    @resources = resources
    unless @resources?
       @items_by_id = {}
       @list.clear() unless @list._disposed
       return
    if params?
      matcher = utils.matchers.object(params)
      filter = (e) => 
        return true if e.data.type is 'load'
        matcher(e.data[@resources.resource_name])
    @resources.listen @resource_update(), filter
    
    if load
      if params?
        @load(resources.where(params))
      else
        @load(resources.all())

  find_by_id: (id) ->
    if @listen_load
      return @items_by_id[id] if @items_by_id[id]?
    items = @list.where(record: {id: (id|0)})
    if items.length
      @items_by_id[id] = items[0]

  load: (data) ->
    for item in data
      @items_by_id[item.id] = @list.add_item(item, true) unless @items_by_id[item.id] and @listen_load
    @list.update('load')

  resource_update: () ->
    @_resource_update ||= (e) =>
      utils.debug 'Restful list event', e.data.type
      @["on_#{e.data.type}"]?.call(@, e.data[@resources.resource_name])

  on_load: ->
    return unless @listen_load
    if @scope?
      @load @resources.where(@scope)
    else
      @load @resources.all()

  on_create: (data) ->
    return unless @listen_create
    unless @find_by_id(data.id)
      @items_by_id[data.id] = @list.add_item data
    # handle temp item created
    else if data.__tid__ and (item = @find_by_id(data.__tid__))
      delete @items_by_id[data.__tid__]
      @items_by_id[data.id] = item
      @list.update_item item, data

  on_destroy: (data) ->
    if (item = @find_by_id(data.id))
      @list.remove_item item
      delete @items_by_id[data.id]
    return

  on_update: (data) ->
    if (item = @find_by_id(data.id))
      @list.update_item item, data

  dispose: ->
    @items_by_id = {}
    @resources.off(@resource_update()) if @resources?