'use strict'
pi = require '../../../core'
require '../../../views/base'
utils = pi.utils

# [Plugin]
# Add method to work with list ('search', 'filter', 'sort' ...)
class pi.BaseView.Listable
  @included: (klass) ->
    klass.requires 'list'

  sort: (params) ->
    @list.sort params        

  sorted: (params) ->
    @list.sortable.sorted(params) if params?

  search: (query) ->
    @_query = query # store query to highlight after update
    @list.search query, true

  searched: (query) ->
    utils.debug "loaded search #{query}"
    @list.searchable.start_search()
    if query
      @list.highlight query
      @list.trigger pi.ListEvent.Searched
    else
      @list.searchable.stop_search(false)

  filter: (data) ->
    @list.filter data

  filtered: (data) ->
    utils.debug "loaded filter", data
    @list.filterable.start_filter()
    if data?
      @list.trigger pi.ListEvent.Filtered
    else
      @list.filterable.stop_filter(false)
   
  clear: (data) ->
    utils.debug 'clear list'
    @list.clear()
    @list.clear_selection()?
    @list.scroll_end?.disable()

  load: (data) ->
    for item in data
      @list.add_item item, true
    @list.update()

  reload: (data) ->
    @list.data_provider data
    @searched(@_query) if @_query