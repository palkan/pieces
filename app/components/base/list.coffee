'use strict'
pi = require '../../core'
require '../pieces'
require '../../plugins/base/renderable'
utils = pi.utils

# Basic list component

class pi.List extends pi.Base
  @include_plugins pi.Base.Renderable

  merge_classes: ['is-disabled', 'is-active', 'is-hidden']

  preinitialize: () ->
    super
    @list_klass = @options.list_klass || 'list'
    @item_klass = @options.item_klass || 'item'

    @items = []
    @buffer = document.createDocumentFragment()

  initialize: () ->
    super
    @items_cont = @find(".#{ @list_klass }") || @
    @parse_html_items()

  postinitialize: () ->
    @_check_empty()
    unless @options.noclick?
      @listen ".#{ @item_klass }", "click", (e) =>  
        unless utils.clickable(e.origTarget)
          if  @_item_clicked(e.target) 
            e.cancel()
  
  parse_html_items: () ->
    @items_cont.each ".#{ @item_klass }", (node) =>   
      @add_item pi.Nod.create(node), true
    @_flush_buffer()

  # Set list elements
  # @params [Array, Null] data if null then clear list

  data_provider: (data = null) ->
    @clear() if @items.length  

    if data?
      @add_item(item,true) for item in data
    
    @update('load')
    @

  add_item: (data, silent = false) ->
    item = @_create_item data
    return unless item?
    
    @items.push item

    @_check_empty()

    # save item index in DOM element
    item.data('list-index',@items.length-1)
    
    unless silent then @items_cont.append(item) else @buffer.appendChild(item.node)

    @trigger('update', {type:'item_added',item:item}) unless silent
    item
    
  add_item_at: (data, index, silent = false) ->
    if @items.length-1 < index
        @add_item data,silent
        return
          
    item = @_create_item data
    @items.splice(index,0,item)
    
    _after = @items[index+1]
    
    # save item index in DOM element
    item.data('list-index',index)
    _after.insertBefore item

    @_need_update_indeces = true

    unless silent
      @_update_indeces()
      @trigger('update', {type:'item_added', item:item})
    item

  remove_item: (item,silent = false) ->
    index = @items.indexOf(item)
    if index > -1
      @items.splice(index,1)
      @_destroy_item(item)

      @_check_empty()

      @_need_update_indeces = true

      unless silent
        @_update_indeces()
        @trigger('update', {type:'item_removed',item:item})
      true
    else
      false

  remove_item_at: (index,silent = false) ->
    if @items.length-1 < index
      return
    
    item = @items[index]
    @remove_item(item,silent)

  remove_items: (items) ->
    for item in items
      @remove_item(item,true)
    @update()
    return

  # redraw item with new data
  # How it works:
  #  1. Render new item for new data
  #  2. Update item html (merge classes)
  #  3. Update item record (by extending it with new item data (overwriting))

  update_item: (item, data, silent=false) ->
    new_item = @_renderer.render data

    # update associated record
    utils.extend item.record, new_item.record, true

    # remove_children
    item.remove_children()

    # update HTML
    item.html new_item.html()

    #try to remove runtime classes
    for klass in item.node.className.split(/\s+/)
      item.removeClass(klass) if klass and !(klass in @merge_classes)
    #merge classes
    item.mergeClasses new_item
    
    # piecify
    item.piecify()

    @trigger('update', {type:'item_updated',item:item}) unless silent
    item  

  move_item: (item, index) ->
    return if (item.data('list-index') is index) || (index>@items.length-1)

    @items.splice @items.indexOf(item), 1

    if index is @items.length
      @items.push item
      @items_cont.append(item)
    else
      @items.splice(index,0,item)
      _after = @items[index+1]
      _after.insertBefore item

    @_need_update_indeces = true
    @_update_indeces()
    item

  # Find items within list using query
  #
  # @params [String, Object] query 
  #
  # @example Find items by object mask (would match all objects that have keys and equal ('==') values)
  #   list.find({age: 20, name: 'John'})
  # @example Find by string query = find by nod content
  #   list.find(".title:keyword") // match all items for which item.nod.find('.title').text().search(/keyword/) > -1

  where: (query) ->
    matcher = if typeof query == "string" then utils.matchers.nod(query) else utils.matchers.object(query)
    item for item in @items when matcher(item)

  records: ->
    @items.map((item) -> item.record)

  size: () ->
    @items.length

  update: (type) ->
    @_flush_buffer()
    @_update_indeces() if @_need_update_indeces
    @_check_empty()
    @trigger 'update', {type: type}

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
      @trigger 'empty', true
    else if @empty and @items.length > 0
      @removeClass 'is-empty'
      @empty = false
      @trigger 'empty', false
    

  _create_item: (data) ->
    if data instanceof pi.Nod and data.is_list_item
      if data.host is @
        return data
      else
        return null
    item = @_renderer.render data
    return unless item?
    item.is_list_item = true
    item.host = @
    item

  _destroy_item: (item) ->
    item.remove()
    item.dispose()

  _flush_buffer: (append = true) ->
    @items_cont.append @buffer if append
    while @buffer.firstChild
     @buffer.removeChild(@buffer.firstChild)

  _item_clicked: (target) ->
    return unless target.is_list_item
    item = target
    if item and item.host is @
      @trigger 'item_click', {item: item}
      true

pi.Guesser.rules_for 'list', ['pi-list'], ['ul'], 
  (nod) -> 
    nod.children('ul').length is 1
