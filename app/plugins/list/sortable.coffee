'use strict'
pi = require '../../core'
require '../../components/base/list'
require '../plugin'
utils = pi.utils
# [Plugin]
#
#  Add 'sort(field,order)' method to list

class pi.List.Sortable extends pi.Plugin
  id: 'sortable'
  initialize: (@list) ->
    super
    # set initial sort order (e.g. 'key1:desc,key2:asc')
    if @list.options.sort?
      @_prevs = []
      for param in @list.options.sort.split(",")
        do(param) =>
          data = {}
          [key,order] = param.split(":")
          data[key] = order
          @_prevs.push data
      @_compare_fun = (a,b) -> utils.keys_compare a.record, b.record, @_prevs

    @list.delegate_to @, 'sort'
    @list.on pi.ListEvent.Update, ((e) => @item_updated(e.data.item)), @, (e) => ((e.data.type is pi.ListEvent.ItemAdded or e.data.type is pi.ListEvent.ItemUpdated) and e.data.item.host is @list) 
    @

  item_updated: (item) ->
    return false unless @_compare_fun
    @_bisect_sort item, 0, @list.size()-1
    false


  _bisect_sort: (item, left, right) ->
    if right-left < 2
      if @_compare_fun(item,@list.items[left])>0
        @list.move_item(item,right)
      else
        @list.move_item(item,left)  
      return
    i = (left+(right-left)/2)|0
    a = @list.items[i]
    if @_compare_fun(item,a)>0
      left = i
    else
      right = i
    @_bisect_sort item, left, right 


  sort: (sort_params) ->
    return unless sort_params?
    sort_params = utils.to_a sort_params
    @_prevs = sort_params
   
    @_compare_fun = (a,b) -> utils.keys_compare a.record, b.record, sort_params

    @list.items.sort @_compare_fun

    @list.data_provider(@list.items.slice(),false,false)
    @list.trigger pi.ListEvent.Sorted, sort_params

  sorted: (sort_params) ->
    return unless sort_params?
    sort_params = utils.to_a sort_params
    @_prevs = sort_params
    @_compare_fun = (a,b) -> utils.keys_compare a.record, b.record, sort_params
    @list.trigger pi.ListEvent.Sorted, sort_params

module.exports = pi.List.Sortable
