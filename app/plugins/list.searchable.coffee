do (context = this) ->
  "use strict"
  # shortcuts
  $ = context.jQuery
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  # [Plugin]
  #
  #  Add 'search' method to list
  #  Search items detaching (not hiding!) DOM elements   
  #  
  #  To search within scope define 'options.search_scope'
  

  _clear_mark_regexp = new RegExp("<mark>([^<>]*)<\/mark>","gim")

  class pi.Searchable
    constructor: (@list) ->
      @matcher_factory = @_matcher_from_scope(@list.options.search_scope)
      @list.searchable = this
      @list.delegate ['search','_start_search','_stop_search', '_highlight_item'], 'searchable'
      @list.searching = false
      return

    _matcher_from_scope: (scope) ->
      @matcher_factory = 
        if not scope?
          utils.string_matcher
        else if (matches = scope.match(/^data:([\w\d\_]+)/))
          obj = {}
          key = matches[1]
          (value) -> 
            obj[key] = value
            utils.object_matcher(obj) 
        else 
          (value) -> utils.string_matcher(scope+':'+value) 

    _is_continuation: (query) ->
      query.match(@_prevq)?.index == 0

    _start_search: () ->
      return if @searching
      @searching = true
      @nod.addClass 'is-searching'
      @_all_items = utils.clone(@items)
      @searchable._prevq = ''
      @trigger 'search_start'

    _stop_search: () ->
      return unless @searching
      @searching = false
      @nod.removeClass 'is-searching'
      @data_provider @_all_items
      @_all_items = null
      @trigger 'search_stop'

    _highlight_item: (query, item) ->
      _raw_html = item.nod.html()
      _regexp = new RegExp("((?:^|>)[^<>]*?)(#{ query })","gim")
      _raw_html = _raw_html.replace(_clear_mark_regexp,"$1")
      _raw_html = _raw_html.replace(_regexp,'$1<mark>$2</mark>') if query isnt ''
      item.nod.html(_raw_html)


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