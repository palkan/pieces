'use strict'
pi = require 'core'
require 'components/base/list'
require '../plugin'
utils = pi.utils
# [Plugin]
#
#  Add 'sort(field,order)' method to list

class pi.List.Sortable extends pi.Plugin
  id: 'sortable'
  initialize: (@list) ->
    super
    @list.delegate_to @, 'sort'
    @list.on 'update', (-> @sort(@_prevs)), @, (e) -> (e.data.type is 'item_added' or e.data.type is 'item_updated') 


  # @params [Array,String] fields
  # @params [Boolean] reverse if true then 'asc' else 'desc'
  # @see pi.utils.sort 
  sort: (sort_params) ->
    sort_params = utils.to_a sort_params
    @_prevs = sort_params
    
    @list.items.sort (a,b) ->
      utils.keys_compare a.record, b.record, sort_params

    @list.data_provider @list.items.slice()
    @list.trigger 'sort_update', sort_params

  sorted: (sort_params) ->
    sort_params = utils.to_a sort_params
    @_prevs = sort_params
    @list.trigger 'sort_update', sort_params