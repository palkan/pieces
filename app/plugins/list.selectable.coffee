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
      
      @list.on 'item_click', (event) =>
        if @type == 'radio' and not event.data.item.selected
          @list.clear_selection()
          @list._select event.data.item
        else if @type == 'check'
          @list._toggle_select event.data.item
        return

      _selected = @list.items_cont.find('.is-selected')

      if _selected.length
        @list.items[_selected.data('list-index')].selected = true

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