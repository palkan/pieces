'use strict'
pi = require '../../core'
require '../../components/base/list'
require '../plugin'
utils = pi.utils

# [Plugin]
#
# Add 'filter' method to list
# Filter items detaching (not hiding!) DOM elements.
_is_continuation = (prev, params) ->
  for own key,val of prev
    if params[key] != val
      return false
  return true

class pi.List.Filterable extends pi.Plugin
  id: 'filterable'

  initialize: (@list) ->
    super
    @list.delegate_to @, 'filter'
    @list.on 'update', ((e) => @item_updated(e.data.item)), 
      @, 
      (e) => ((e.data.type is 'item_added' or e.data.type is 'item_updated') and e.data.item.host is @list) 

  item_updated: (item) ->
    return false unless @matcher

    if @_all_items.indexOf(item)<0
      @_all_items.unshift item

    if @matcher(item)
      return
    else if @filtered
      @list.remove_item item, true

    false

  all_items: ->
    @_all_items.filter((item) -> !item._disposed)

  start_filter: () ->
    return if @filtered
    @filtered = true
    @list.addClass 'is-filtered'
    @_all_items = @list.items.slice()
    @_prevf = {}
    @list.trigger 'filter_start'

  stop_filter: (rollback=true) ->
    return unless @filtered
    @filtered = false
    @list.removeClass 'is-filtered'
    @list.data_provider(@all_items()) if rollback
    @_all_items = null
    @matcher = null
    @list.trigger 'filter_stop'


  # Filter list items.
  # @param [Object] params 

  filter: (params) ->
    unless params?
      return @stop_filter()

    @start_filter() unless @filtered

    scope = if _is_continuation(@_prevf, params) then @list.items.slice() else @all_items()

    @_prevf = params

    @matcher = utils.matchers.object_ext record: params

    _buffer = (item for item in scope when @matcher(item))
    @list.data_provider _buffer

    @list.trigger 'filter_update'