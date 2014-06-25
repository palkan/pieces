do (context = this) ->
  "use strict"
  # shortcuts
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  # [Plugin]
  #
  #  Add 'search' method to list
  #  Search items detaching (not hiding!) DOM elements   
  #  
  #  To search within scope define 'options.search_scope'
  

  _clear_mark_regexp = /<mark>([^<>]*)<\/mark>/gim
  _selector_regexp = /[\.#a-z\s\[\]=\"-_]/i


  class pi.Searchable
    constructor: (@list) ->
      @update_scope @list.options.search_scope
      @list.searchable = this
      @list.delegate ['search','_start_search','_stop_search', '_highlight_item'], 'searchable'
      @list.searching = false
      return

    update_scope: (scope) -> 
      @matcher_factory = @_matcher_from_scope(scope)
      if (scope && _selector_regexp.test(scope))
        @list._highlight_element = (item) -> item.nod.find(scope) 
      else 
        @list._highlight_element = (item) -> item.nod 

    _matcher_from_scope: (scope) ->
      @matcher_factory = 
        if not scope?
          pi.List.string_matcher
        else if (matches = scope.match(/^data:([\w\d_]+)/))
          obj = {}
          key = matches[1]
          (value) -> 
            obj[key] = value
            utils.object_matcher(obj) 
        else 
          (value) -> pi.List.string_matcher(scope+':'+value) 

    _is_continuation: (query) ->
      query.match(@_prevq)?.index == 0

    _start_search: () ->
      return if @searching
      @searching = true
      @addClass 'is-searching'
      @_all_items = utils.clone(@items)
      @searchable._prevq = ''
      @trigger 'search_start'

    _stop_search: () ->
      return unless @searching
      @searching = false
      @removeClass 'is-searching'
      @data_provider @_all_items
      @_all_items = null
      @trigger 'search_stop'

    _highlight_item: (query, item) ->
      nod = @_highlight_element item
      _raw_html = nod.html()
      _regexp = new RegExp "((?:^|>)[^<>]*?)(#{ query })", "gim"
      _raw_html = _raw_html.replace(_clear_mark_regexp,"$1")
      _raw_html = _raw_html.replace(_regexp,'$1<mark>$2</mark>') if query isnt ''
      nod.html(_raw_html)

    # Local search thru items.
    # @param q query (string ot object)
    # @param highlight [optional] defines whether to highlight matches with <mark> tag. Can be boolean or highlight scope (highlited element selector) 
    #

    search: (q = '', highlight = false) ->
      if q is ''
        return @_stop_search()

      @_start_search() unless @searching

      scope = if @searchable._is_continuation(q) then @items.slice() else utils.clone(@_all_items)

      @searchable._prevq = q

      matcher = @searchable.matcher_factory q

      _buffer = (item for item in scope when matcher(item))
      @data_provider _buffer

      if highlight
        @_highlight_item(q,item) for item in _buffer

      @trigger 'search_update'