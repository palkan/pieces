do (context = this) ->
  "use strict"
  # shortcuts
  $ = context.jQuery
  pi = context.pi  = context.pi || {}
  utils = pi.utils
   
  # [Plugin]
  # Add ability to 'select' elements within list
  # 
  # Highlights selected elements with 'is-selected' class 

  class pi.Selectable
    constructor: (@list) ->
      @type = @list.options.select || 'radio' 
      
      @list.on 'item_click', @item_click_handler()

      @list.on 'update', @update_handler()

      _selected = @list.items_cont.find('.is-selected')

      if _selected.length
        @list.items[_selected.data('list-index')].selected = true

      @list.selectable = this
      @list.delegate ['clear_selection','selected','selected_item','select_all','_select','_deselect','_toggle_select'], 'selectable'

      return

    item_click_handler: ->
      return @_item_click_handler if @_item_click_handler
      @_item_click_handler = (e) =>
        if @type.match('radio') and not e.data.item.selected
          @list.clear_selection(true)
          @list._select e.data.item
          @list.trigger 'selected'
        else if @type.match('check')
          @list._toggle_select e.data.item
          if @list.selected().length then @list.trigger('selected') else @list.trigger('selection_cleared')
        return      

    update_handler: ->
      return @_update_handler if @_update_handler
      @_update_handler = (e) =>
        @_check_selected() unless e.data?.type? and e.data.type is 'item_added'

    _check_selected: ->
      @list.trigger('selection_cleared') if !@list.selected().length

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

    clear_selection: (silent = false) ->
      @_deselect(item) for item in @items
      @trigger('selection_cleared') unless silent
    
    select_all: () ->
      @_select(item) for item in @items
      @trigger('selected') if @selected().length


    # Return selected items
    # @returns [Array]
  
    selected: () ->
      item for item in @items when item.selected

    selected_item: ()->
      _ref = @selected()
      if _ref.length then _ref[0] else null
