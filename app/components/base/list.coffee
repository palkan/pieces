do (context = this) ->
  "use strict"
  # shortcuts
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  _renderer_reg = /(\w+)(?:\(([\w\-\/]+)\))?/

  # Basic list component

  class pi.List extends pi.Base

    @string_matcher = (string) ->
      if string.indexOf(":") > 0
        [selectors, query] = string.split ":"
        regexp = new RegExp(query,'i')
        selectors = selectors.split ','
        (item) ->
          for selector in selectors
            return true if !!item.find(selector)?.text().match(regexp)
          return false
      else
        regexp = new RegExp(string,'i')
        (item) ->
          !!item.text().match(regexp)

    @object_matcher = (obj, all = true) ->
      for key,val of obj
        do (key,val) ->
          if typeof val is "string"
            obj[key] = (value) -> 
              !!value.match new RegExp(val,'i')
          else if !(typeof val is 'function')
            obj[key] = (value) ->
              val == value

      (item) ->
        _any = false
        for key,matcher of obj
          if item[key]?
            if matcher(item[key])
              _any = true
              return _any unless all
            else
              return false if all
        return _any

    preinitialize: () ->
      super
      @list_klass = @options.list_klass || 'list'
      @item_klass = @options.item_klass || 'item'

      @items = []
      @buffer = document.createDocumentFragment()

    initialize: () ->
      @item_renderer ||= @_setup_renderer()
      @items_cont = @find(".#{ @list_klass }") || @
      @parse_html_items()

    postinitialize: () ->
      @_check_empty()
      unless @options.noclick?
        @listen ".#{ @item_klass }", "click", (e) =>  
          unless utils.clickable(e.origTarget)
            @_item_clicked(e.target) 
            e.cancel()
    
    parse_html_items: () ->
      @items_cont.each ".#{ @item_klass }", (node) =>   
        @add_item pi.Nod.create(node)
      @_flush_buffer false

    # Set list elements
    # @params [Array, Null] data if null then clear list

    data_provider: (data = null) ->
      @clear() if @items.length  
  
      if data?
        @add_item(item,false) for item in data
      
      @update()

    add_item: (data, update = true) ->
      item = @_create_item data
      @items.push item

      @_check_empty()

      # save item index in DOM element
      item.data('list-index',@items.length-1)
      
      if update then @items_cont.append(item) else @buffer.appendChild(item.node)

      @trigger('update', {type:'item_added',item:item}) if update
      
    add_item_at: (data, index, update = true) ->
      if @items.length-1 < index
          @add_item data,update
          return
            
      item = @_create_item data
      @items.splice(index,0,item)
      
      _after = @items[index+1]
      
      # save item index in DOM element
      item.data('list-index',index)
      _after.insertBefore item

      @_need_update_indeces = true

      if update
        @_update_indeces()
        @trigger('update', {type:'item_added', item:item})

    remove_item: (item,update = true) ->
      index = @items.indexOf(item)
      if index > -1
        @items.splice(index,1)
        @_destroy_item(item)

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
      matcher = if typeof query == "string" then @constructor.string_matcher(query) else @constructor.object_matcher(query)
      item for item in @items when matcher(item)


    size: () ->
      @items.length

    update: () ->
      @_flush_buffer()
      @_update_indeces() if @_need_update_indeces
      @_check_empty()
      @trigger 'update'

    clear: () ->
      @items_cont.detach_children()
      @items.length = 0
      @trigger 'update', {type:'clear'}

    _update_indeces: ->
      item.data('list-index',i) for item,i in @items
      @_need_update_indeces = false

    _check_empty: ->
      if !@empty and @items.length is 0
        @addClass 'is-empty'
        @empty = true
        @trigger 'empty'
      else if @empty and @items.length > 0
        @removeClass 'is-empty'
        @empty = false
        @trigger 'is-full'
      

    _create_item: (data) ->
      if data instanceof pi.Nod and data.is_list_item
        return data
      item = @item_renderer.render data
      item.is_list_item = true
      item

    _destroy_item: (item) ->
      item.remove()
      item.dispose()

    _setup_renderer: ->
      if @options.renderer? and _renderer_reg.test(@options.renderer)
        [_, name, param] = @options.renderer.match _renderer_reg
        klass = pi.List.Renderers[utils.camelCase(name)]
        if klass?
          return new klass(param)
      new pi.List.Renderers.Base()


    _flush_buffer: (append = true) ->
      @items_cont.append @buffer if append
      @buffer.innerHTML = ''

    _item_clicked: (target,e) ->
      return unless target.data('list-index')?
      item = @items[target.data('list-index')]
      @trigger 'item_click', {item: item}

  pi.List.Renderers = {}

  class pi.List.Renderers.Base
    render: (nod) ->
      @_render nod, nod.data() 

    _render: (nod, data) ->
      unless nod instanceof pi.Base
        nod = nod.piecify()
      utils.extend nod, data
      nod

  pi.Guesser.rules_for 'list', ['pi-list'], ['ul'], 
    (nod) -> 
      nod.children('ul').length is 1
