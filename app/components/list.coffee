do (context = this) ->
  "use strict"
  # shortcuts
  $ = context.jQuery
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  list_klass = pi.config.list?.list_klass? || 'list'
  item_klass = pi.config.list?.item_klass? || 'item'


  object_matcher = (obj) ->
    for key,val of obj
      if typeof val == "string"
        obj[key] = (value) -> 
          !!value.match new RegExp(val)
      else if val instanceof Object
        obj[key] = object_matcher val
      else
        obj[key] = (value) ->
          val == value

    (item) ->
      for key,matcher of obj
        unless item[key]? and matcher(item[key])
          return false
      return true

  string_matcher = (string) ->
    if string.indexOf(":") > 0
      [path, query] = string.split ":"
      regexp = new RegExp(query)
      (item) ->
        !!item.nod.find(path).text().match(regexp)
    else
      regexp = new RegExp(string)
      (item) ->
        !!item.nod.text().match(regexp)

  # Basic list component

  class pi.List extends pi.Base
    initialize: () ->
      @items_cont = @nod.find(".#{ list_klass }")
      @item_renderer = @options.renderer
      
      unless @item_renderer?
        @item_renderer = (nod) -> 
          item = nod.data()
          item.nod = nod
          item

      @items = []
      @buffer = document.createDocumentFragment()
    
      @parse_html_items()

      @nod.on "click", ".#{ item_klass }", (e) =>  @_item_clicked($(` this `),e)

    parse_html_items: () ->
      @add_item($(nod)) for nod in @items_cont.find(".#{ item_klass }")
      @_flush_buffer false

    # Set list elements
    # @params [Array, Null] data if null then clear list

    data_provider: (data = null) ->
      @clear() if @items.length  

      return unless data? 
      
      @add_item(item,false) for item in data
      @_flush_buffer()
      @trigger 'update'

    add_item: (data, update = true) ->
      item = @_create_item data
      @items.push item

      # save item index in DOM element
      item.nod.data('list-index',@items.length-1)
      
      if update then @items_cont.append(item.nod) else @buffer.appendChild(item.nod.get(0))

      @trigger('update', {type:'item_added',item:item}) if update
      
    add_item_at: (data, index, update = true) ->
      if @items.length-1 < index
          @add_item data,update
          return
            
      item = @_create_item data
      @items.splice(index,0,item)
      
      _after = @items[index+1]
      
      # save item index in DOM element
      item.nod.data('list-index',index)

      item.nod.insertBefore(_after.nod)

      @trigger('update', {type:'item_added', item:item}) if update

    remove_item: (item,update = true) ->
      index = @items.indexOf(item)
      if index > -1
        @items.splice(index,1)
        @_destroy_item(item)
        item.nod.data('list-index','')
        @trigger('update', {type:'item_removed',item:item}) if update
      return  

    remove_item_at: (index,update = true) ->
      if @items.length-1 < index
        return
      
      item = @items[index]
      @remove_item(item,update)


    # Find items within list using query
    #
    # @params [String, Object] query 
    #
    # @example Find items by object mask (would match all objects that have keys and equal ('==') values)
    #   list.find({age: 20, name: 'John'})
    # @example Find by string query = find by nod content
    #   list.find(".title:keyword") // match all items for which item.nod.find('.title').text().search(/keyword/) > -1

    find: (query) ->
      matcher = if typeof query == "string" then string_matcher(query) else object_matcher(query)
      item for item in @items when matcher(item)


    size: () ->
      @items.length

    clear: () ->
      @items_cont.children().detach()
      @items.length = 0
      @trigger 'update', {type:'clear'}

    _create_item: (data) ->
      return data if data.nod instanceof $ 
      @item_renderer data

    _destroy_item: (item) ->
      item.nod?.remove?()

    _flush_buffer: (append = true) ->
      @items_cont.append @buffer if append
      @buffer = document.createDocumentFragment()

    _item_clicked: (target,e) ->
      return unless target.data('list-index')?
      item = @items[target.data('list-index')]
      @trigger 'item_click', { item: item}


  # [Plugin]
  # Dispatch 'autoload' event when list is scrolled to bottom
  #

  class pi.Autoload
    constructor: (@list) ->
      @scroll_object = if @list.options.scroll_object == 'window' then $(document.body) else @list.items_cont
      @list.autoload = this
      
      @_prev_top = @scroll_object[0].scrollTop

      @_wait = false

      @_scroll_listener = (event) =>
        utils.debug 'scroll'
        if not @_wait and @_prev_top < @scroll_object[0].scrollTop and @scroll_object[0].scrollHeight - @scroll_object[0].scrollTop - @scroll_object[0].clientHeight  < 50
          utils.debug 'autoload'
          @list.trigger 'autoload'
          @_wait = true
          after 500, => 
            @_wait = false 

      @enable() unless @list.options.autoload is false


      return

    enable: () ->
      @scroll_object.on 'scroll', @_scroll_listener 

    disable: () ->
      @scroll_object.off 'scroll', @_scroll_listener      



  # [Plugin]
  # Add ability to 'select' elements within list
  # 
  # Highlights selected elements with 'is-selected' class 

  class pi.Selectable
    constructor: (@list) ->
      @type = @list.options.select || 'radio' 
      
      @list.on 'item_click', (event) =>
        if @type == 'radio' and not event.data.item.selected
          @list.clear_selection()
        @list._toggle_select event.data.item
        return
      @list.selectable = this
      @list.delegate ['clear_selection','selected','select_all','_select','_deselect','_toggle_select'], 'selectable'

      return

    _select: (item) ->
      if not item.selected
        item.selected = true
        item.nod.addClass 'is-selected'

    _deselect: (item) ->
      if item.selected
        item.selected = false
        item.nod.removeClass 'is-selected'
    
    _toggle_select: (item) ->
      if item.selected then @_deselect(item) else @_select(item)

    clear_selection: () ->
      @_deselect(item) for item in @items
    
    select_all: () ->
      @_select(item) for item in @items


    # Return selected items
    # @returns [Array]
  
    selected: () ->
      item for item in @items when item.selected

  # [Plugin]
  #
  #  Add 'search' method to list
  #  Search items detaching (not hiding!) DOM elements   
  #  
  #  To search within scope define 'options.search_scope'
  

  class pi.Searchable
    constructor: (@list) ->
      @matcher_factory = @_matcher_from_scope(@list.options.search_scope)
      @list.searchable = this
      @list.delegate ['search','_start_search','_stop_search'], 'searchable'
      @list.searching = false
      return

    _matcher_from_scope: (scope) ->
      @matcher_factory = 
        if not scope?
          string_matcher
        else if (matches = scope.match(/^data:([\w\d\_]+)/))
          obj = {}
          key = matches[1]
          (value) -> 
            obj[key] = value
            object_matcher(obj) 
        else 
          (value) -> string_matcher(scope+':'+value) 

    _is_continuation: (query) ->
      query.match(@_prevq)?.index == 0

    _start_search: () ->
      return if @searching
      @searching = true
      @nod.addClass 'is-searching'
      @_all_items = utils.clone(@items)
      @_prevq = ''
      @trigger 'search_start'

    _stop_search: () ->
      return unless @searching
      @searching = false
      @nod.removeClass 'is-searching'
      @data_provider @_all_items
      @_all_items = null
      @trigger 'search_stop'

    search: (q) ->
      unless q?
        return @_stop_search()

      @_start_search() unless @searching

      scope = if @searchable._is_continuation(q) then @items else @_all_items

      @searchable._prevq = q

      matcher = @searchable.matcher_factory q

      _buffer = (item for item in @items when matcher(item))
      @data_provider _buffer
      @trigger 'search_update'