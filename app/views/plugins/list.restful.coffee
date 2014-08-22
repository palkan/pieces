'use strict'
pi = require '../../core'
require '../../plugins/plugin'
require '../../components/base/list'
utils = pi.utils

# [Plugin]
#
# Bind resources to List (handle create, update and destroy events)  
class pi.List.Restful extends pi.Plugin
  id: 'restful'
  initialize: (@list) ->
    super
    @items_by_id = {}
    if @list.options.rest? and $r[utils.camelCase(@list.options.rest)]?
      resources = $r[utils.camelCase(@list.options.rest)]
      @bind resources, @list.options.load_rest

    @list.delegate_to @, 'find_by_id'
    return

  bind: (resources, load = false) ->
    if @resources
      @resources.off @resources_update()
    @resources = resources
    @resources.listen @resource_update()
    @load(resources.all()) if load

  find_by_id: (id) ->
    return @items_by_id[id] if @items_by_id[id]?
    items = @list.where(record: {id: (id|0)})
    if items.length
      @items_by_id[id] = items[0]

  load: (data) ->
    for item in data
      @items_by_id[item.id] = @list.add_item item, true
    @list.update()

  resource_update: () ->
    @_resource_update ||= (e) =>
      utils.debug 'Restful list event', e.data.type
      @["on_#{e.data.type}"]?.call(@, e.data[@resources.resource_name])

  on_create: (data) ->
    @items_by_id[data.id] = @list.add_item data

  on_destroy: (data) ->
    if (item = @find_by_id(data.id))
      @list.remove_item item
      delete @items_by_id[item.id]

  on_update: (data) ->
    if (item = @find_by_id(data.id))
      @list.update_item item, data
