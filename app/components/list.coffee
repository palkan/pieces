do (context = this) ->
  "use strict"
  # shortcuts
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  list_klass = pi.config.list?.list_klass? || 'list'
  item_klass = pi.config.list?.item_klass? || 'item'

  # Basic list component

  class pi.List extends pi.Base

    @string_matcher = (string) ->
      if string.indexOf(":") > 0
        [path, query] = string.split ":"
        regexp = new RegExp(query,'i')
        (item) ->
          !!item.nod.find(path).text().match(regexp)
      else
        regexp = new RegExp(string,'i')
        (item) ->
          !!item.nod.text().match(regexp)

    initialize: () ->
      @items_cont = @find(".#{ list_klass }")
      @items_cont = @ unless @items_cont
      @item_renderer = @options.renderer
      
      unless @item_renderer?
        @item_renderer = (nod) -> 
          item = {}
          (item[utils.snake_case(key)]=utils.serialize(val)) for own key,val of nod.data()
          item.nod = nod
          item

      @items = []
      @buffer = document.createDocumentFragment()
    
      @parse_html_items()

      @_check_empty()

      @listen ".#{ item_klass }", "click", (e) =>  
        @_item_clicked(e.target) unless e.origTarget.nodeName is 'A'
      super

    parse_html_items: () ->
      @items_cont.each ".#{ item_klass }", (node) =>   
        @add_item pi.Nod.create(node)
      @_flush_buffer false

    # Set list elements
    # @params [Array, Null] data if null then clear list

    data_provider: (data = null) ->
      @clear() if @items.length  

      unless data? and data.length
        @_check_empty()
        return

      @add_item(item,false) for item in data
      
      @update()

    add_item: (data, update = true) ->
      item = @_create_item data
      @items.push item

      @_check_empty()

      # save item index in DOM element
      item.nod.data('listIndex',@items.length-1)
      
      if update then @items_cont.append(item.nod) else @buffer.appendChild(item.nod.node)

      @trigger('update', {type:'item_added',item:item}) if update
      
    add_item_at: (data, index, update = true) ->
      if @items.length-1 < index
          @add_item data,update
          return
            
      item = @_create_item data
      @items.splice(index,0,item)
      
      _after = @items[index+1]
      
      # save item index in DOM element
      item.nod.data('listIndex',index)
      _after.nod.insertBefore item.nod

      @_need_update_indeces = true

      if update
        @_update_indeces()
        @trigger('update', {type:'item_added', item:item})

    remove_item: (item,update = true) ->
      index = @items.indexOf(item)
      if index > -1
        @items.splice(index,1)
        @_destroy_item(item)
        item.nod.data('listIndex',null)

        @_check_empty()

        @_need_update_indeces = true

        if update
          @_update_indeces()
          @trigger('update', {type:'item_removed',item:item})
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

    where: (query) ->
      matcher = if typeof query == "string" then @constructor.string_matcher(query) else utils.object_matcher(query)
      item for item in @items when matcher(item)


    size: () ->
      @items.length

    update: () ->
      @_flush_buffer()
      @_update_indeces() if @_need_update_indeces
      @trigger 'update'

    clear: () ->
      @items_cont.detach_children()
      @items.length = 0
      @trigger 'update', {type:'clear'}

    _update_indeces: ->
      item.nod.data('listIndex',i) for item,i in @items
      @_need_update_indeces = false

    _check_empty: ->
      if !@empty and @items.length is 0
        @addClass 'is-empty'
        @empty = true
        @trigger 'empty'
      else if @empty and @items.length > 0
        @removeClass 'is-empty'
        @empty = false
        @trigger 'full'
      

    _create_item: (data) ->
      return data if data.nod instanceof pi.Nod
      @item_renderer data

    _destroy_item: (item) ->
      item.nod?.remove?()

    _flush_buffer: (append = true) ->
      @items_cont.append @buffer if append
      @buffer.innerHTML = ''

    _item_clicked: (target,e) ->
      return unless target.data('listIndex')?
      item = @items[target.data('listIndex')]
      @trigger 'item_click', {item: item}