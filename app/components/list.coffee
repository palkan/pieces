do (context = this) ->
  "use strict"
  # shortcuts
  $ = context.jQuery
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  list_klass = pi.config.list?.list_klass? || 'list'
  item_klass = pi.config.list?.item_klass? || 'item'

  # Basic list component

  class pi.List extends pi.Base
    initialize: () ->
      @items_cont = @nod.find(".#{ list_klass }")
      @items_cont = @nod unless @items_cont.length
      @item_renderer = @options.renderer
      
      unless @item_renderer?
        @item_renderer = (nod) -> 
          item = {}
          (item[utils.snakeCase(key)]=val) for own key,val of nod.data()
          item.nod = nod
          item

      @items = []
      @buffer = document.createDocumentFragment()
    
      @parse_html_items()

      @nod.addClass 'is-empty' if @empty()

      @nod.on "click", ".#{ item_klass }", (e) =>  @_item_clicked($(` this `),e)

    parse_html_items: () ->
      @add_item($(nod)) for nod in @items_cont.find(".#{ item_klass }")
      @_flush_buffer false

    # Set list elements
    # @params [Array, Null] data if null then clear list

    data_provider: (data = null) ->
      @clear() if @items.length  

      unless data? and data.length
         @nod.addClass 'is-empty'
         return

      @add_item(item,false) for item in data
      @_flush_buffer()
      @trigger 'update'

    add_item: (data, update = true) ->
      item = @_create_item data
      @items.push item

      @nod.removeClass 'is-empty' if @size() == 1

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

        @nod.addClass 'is-empty' if @empty()

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
      matcher = if typeof query == "string" then utils.string_matcher(query) else utils.object_matcher(query)
      item for item in @items when matcher(item)


    size: () ->
      @items.length

    empty: () ->
      @size() is 0

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