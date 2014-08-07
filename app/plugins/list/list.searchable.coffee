do (context = this) ->
  "use strict"
  # shortcuts
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  # [Plugin]
  #
  #  Add 'search' method to list
  #  Search items detaching (not hiding!) DOM elements  ## note: but why? 
  #  
  #  To search within scope define 'options.search_scope'.
  #  
  #  Scope is: 
  #  - a CSS selector (or selectors separated by commas), e.g. '.title,.email' (no spaces between selectors!)
  #  - item object keys written as "data:key1,data:key2" to be matched (no spaces between keys!)
  #  

  _clear_mark_regexp = /<mark>([^<>]*)<\/mark>/gim
  _selector_regexp = /[\.#a-z\s\[\]=\"-_,]/i
  _data_regexp = /data:([\w\d_]+)/gi

  _is_continuation = (prev,query) ->
    query.match(prev)?.index == 0

  class pi.List.Searchable extends pi.Plugin
    initialize: (@list) ->
      super
      @update_scope @list.options.search_scope
      @list.delegate_to 'searchable', 'search'
      @searching = false
      return

    update_scope: (scope) -> 
      @matcher_factory = @_matcher_from_scope(scope)
      if (scope && _selector_regexp.test(scope))
        @_highlight_elements = (item) -> item.find(selector) for selector in scope.split(',') 
      else 
        @_highlight_elements = (item) -> [item] 

    _matcher_from_scope: (scope) ->
      @matcher_factory = 
        if not scope?
          pi.List.string_matcher
        else if _data_regexp.test(scope)
          scope = scope.replace _data_regexp, "$1"
          obj = {}
          keys = scope.split ","
          (value) -> 
            obj[key] = value for key in keys
            pi.List.object_matcher(obj, false) 
        else 
          (value) -> 
            pi.List.string_matcher(scope+':'+value) 

    all_items: ->
      @_all_items.filter((item) -> !item._disposed)

    start_search: () ->
      return if @searching
      @searching = true
      @list.addClass 'is-searching'
      @_all_items = @list.items.slice()
      @_prevq = ''
      @list.trigger 'search_start'

    stop_search: () ->
      return unless @searching
      @searching = false
      @list.removeClass 'is-searching'
      items = @all_items()
      @clear_highlight items
      @list.data_provider items
      @_all_items = null
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

    # Local search thru items.
    # @param [String,Object] q query
    # @param [Boolean] highlight defines whether to highlight matches with <mark> tag. Default is false.
    #

    search: (q = '', highlight = false) ->
      if q is ''
        return @stop_search()

      @start_search() unless @searching

      scope = if _is_continuation(@_prevq, q) then @list.items.slice() else @all_items()

      @_prevq = q

      matcher = @matcher_factory q

      _buffer = (item for item in scope when matcher(item))
      @list.data_provider _buffer

      if highlight
        @highlight_item(q,item) for item in _buffer

      @list.trigger 'search_update'