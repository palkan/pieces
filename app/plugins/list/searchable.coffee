'use strict'
pi = require '../../core'
require '../../components/base/list'
require '../plugin'
utils = pi.utils
# [Plugin]
#
#  Add 'search' method to list
#  Search items detaching (not hiding!) DOM elements 
#  
#  To search within scope define 'options.search_scope'.
#  
#  Scope is a CSS selector (or selectors separated by commas), e.g. '.title,.email' (no spaces between selectors!)
#  

_clear_mark_regexp = /<mark>([^<>]*)<\/mark>/gim
_selector_regexp = /[\.#a-z\s\[\]=\"-_,]/i

_is_continuation = (prev,query) ->
  query.match(prev)?.index == 0

class pi.List.Searchable extends pi.Plugin
  id: 'searchable'
  initialize: (@list) ->
    super
    @update_scope @list.options.search_scope
    @list.delegate_to @, 'search', 'highlight'
    @searching = false
    @list.on 'update', ((e) => @item_updated(e.data.item)), 
      @, 
      (e) => (e.data.type is 'item_added' or e.data.type is 'item_updated') 
    return

  item_updated: (item) ->
    return unless @matcher

    if @_all_items.indexOf(item)<0
      @_all_items.unshift item

    if @matcher(item)
      @highlight_item @_prevq, item
      return
    else if @searching
      @list.remove_item item, true

  update_scope: (scope) -> 
    @matcher_factory = @_matcher_from_scope(scope)
    if (scope && _selector_regexp.test(scope))
      @_highlight_elements = (item) -> item.find(selector) for selector in scope.split(',') 
    else 
      @_highlight_elements = (item) -> [item] 

  _matcher_from_scope: (scope) ->
    @matcher_factory = 
      if not scope?
        (value) ->
          utils.matchers.nod value
      else 
        (value) -> 
          utils.matchers.nod(scope+':'+value) 

  all_items: ->
    @_all_items.filter((item) -> !item._disposed)

  start_search: () ->
    return if @searching
    @searching = true
    @list.addClass 'is-searching'
    @_all_items = @list.items.slice()
    @_prevq = ''
    @list.trigger 'search_start'

  stop_search: (rollback = true) ->
    return unless @searching
    @searching = false
    @list.removeClass 'is-searching'
    items = @all_items()
    @clear_highlight items
    @list.data_provider(items) if rollback
    @_all_items = null
    @matcher = null
    @list.trigger 'search_stop'

  clear_highlight: (nodes) ->
    for nod in nodes
      _raw_html = nod.html()
      _raw_html = _raw_html.replace(_clear_mark_regexp,"$1")
      nod.html(_raw_html)

  highlight_item: (query, item) ->
    nodes = @_highlight_elements item
    for nod in nodes when nod?
      _raw_html = nod.html()
      _regexp = new RegExp "((?:^|>)[^<>]*?)(#{ query })", "gim"
      _raw_html = _raw_html.replace(_clear_mark_regexp,"$1")
      _raw_html = _raw_html.replace(_regexp,'$1<mark>$2</mark>') if query isnt ''
      nod.html(_raw_html)

  highlight: (q) ->
    @_prevq = q
    @highlight_item(q,item) for item in @list.items
    return

  # Local search thru items.
  # @param [String,Object] q query
  # @param [Boolean] highlight defines whether to highlight matches with <mark> tag. Default is false.

  search: (q = '', highlight) ->
    if q is ''
      return @stop_search()

    highlight = @list.options.highlight unless highlight?

    @start_search() unless @searching

    scope = if _is_continuation(@_prevq, q) then @list.items.slice() else @all_items()

    @_prevq = q

    @matcher = @matcher_factory q

    _buffer = (item for item in scope when @matcher(item))
    @list.data_provider _buffer

    if highlight
      @highlight(q)
    @list.trigger 'search_update'