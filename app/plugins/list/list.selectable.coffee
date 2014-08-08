do (context = this) ->
  "use strict"
  # shortcuts
  pi = context.pi  = context.pi || {}
  utils = pi.utils
   
  # [Plugin]
  # Add ability to 'select' elements within list
  # 
  # Highlights selected elements with 'is-selected' class 

  class pi.List.Selectable extends pi.Plugin
    initialize: (@list) ->
      super
      @type(@list.options.select_type || 'radio') 
      
      @list.on 'item_click', @item_click_handler() # TODO: overwrite _item_clicked

      @list.on 'update', @update_handler()

      @list.items_cont.each '.is-selected', (nod) =>
        nod.selected = true

      @list.delegate_to 'selectable', 'clear_selection','selected','selected_item','select_all','select_item','deselect_item','toggle_select'

      return

    type: (value) ->
      @is_radio = value.match 'radio'
      @is_check = value.match 'check'

    item_click_handler: ->
      @_item_click_handler ||= (e) =>
        if @is_radio and not e.data.item.selected
          @list.clear_selection(true)
          @list.select_item e.data.item
          @list.trigger 'selected', e.data.item
        else if @is_check
          @list.toggle_select e.data.item
          if @list.selected().length then @list.trigger('selected', @selected()) else @list.trigger('selection_cleared')
        return      

    update_handler: ->
      @_update_handler ||= (e) =>
        @_check_selected() unless e.data?.type? and e.data.type is 'item_added'

    _check_selected: ->
      @list.trigger('selection_cleared') unless @list.selected().length

    select_item: (item) ->
      if not item.selected
        item.selected = true
        @_selected = null  #TODO: add more intelligent cache
        item.addClass 'is-selected'

    deselect_item: (item) ->
      if item.selected
        item.selected = false
        @_selected = null
        item.removeClass 'is-selected'
    
    toggle_select: (item) ->
      if item.selected then @deselect_item(item) else @select_item(item)

    clear_selection: (silent = false) ->
      @deselect_item(item) for item in @list.items
      @list.trigger('selection_cleared') unless silent
    
    select_all: () ->
      @select_item(item) for item in @list.items
      @list.trigger('selected', @selected()) if @selected().length


    # Return selected items
    # @returns [Array]
  
    selected: () ->
      unless @_selected?
        @_selected = @list.where(selected: true)
      @_selected

    selected_item: ()->
      _ref = @selected()
      if _ref.length then _ref[0] else null
