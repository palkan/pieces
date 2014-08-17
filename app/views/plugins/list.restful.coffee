pi = require 'core'
require 'plugins/plugin'
require 'components/base/list'
utils = pi.utils

# [Plugin]
#
# Bind resources to List (handle create, update and destroy events)  
class pi.List.Restful extends pi.Plugin
  id: 'restful'
  initialize: (@list) ->
    super
    if @list.options.rest? and $r[utils.camelCase(@list.options.rest)]?
      @resources = $r[utils.camelCase(@list.options.rest)]
      @resources.listen @resource_update()

      @list.delegate_to @, 'find_by_id'
    return

  find_by_id: (id) ->
    items = @list.where(record: {id: (id|0)})
    if items.length
      items[0]

  resource_update: () ->
    @_resource_update ||= (e) =>
      utils.debug 'Resful list event', e.data.type
      @["on_#{e.data.type}"]?.call(@, e.data[@resources.resource_name])

  on_create: (data) ->
    @list.add_item data

  on_destroy: (data) ->
    if (item = @find_by_id(data.id))
      @list.remove_item item

  on_update: (data) ->
    if (item = @find_by_id(data.id))
      @list.update_item item, data
