pi = require 'core'
require 'components/base/list'
require '../plugin'
utils = pi.utils
# [Plugin]
# Add ability to 'select' elements within list
# 
# Highlights selected elements with 'is-selected' class 

class pi.List.Selectable extends pi.Plugin
  id: 'selectable'
  initialize: (@list) ->
    super
    @type(@list.options.select_type || 'radio') 
    
    @list.on 'item_click', @item_click_handler() # TODO: overwrite _item_clicked

    @list.on 'update', @update_handler()

    @list.items_cont.each '.is-selected', (nod) =>
      nod.selected = true

    @list.delegate_to @, 'clear_selection','selected','selected_item','select_all','select_item', 'selected_records', 'selected_record', 'deselect_item','toggle_select', 'selected_size'

    return

  type: (value) ->
    @is_radio = !!value.match('radio')
    @is_check = !!value.match('check')

  item_click_handler: ->
    @_item_click_handler ||= (e) =>
      return unless e.data.item.enabled

      if @is_radio and not e.data.item.__selected__
        @clear_selection(true) # here we only want to clear selection on this list
        @list.select_item e.data.item
        @list.trigger 'selected', [e.data.item]
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
    if not item.__selected__
      item.__selected__ = true
      @_selected = null  #TODO: add more intelligent cache
      item.addClass 'is-selected'

  deselect_item: (item) ->
    if item.__selected__
      item.__selected__ = false
      @_selected = null
      item.removeClass 'is-selected'
  
  toggle_select: (item) ->
    if item.__selected__ then @deselect_item(item) else @select_item(item)

  clear_selection: (silent = false) ->
    @deselect_item(item) for item in @list.items
    @list.trigger('selection_cleared') unless silent
  
  select_all: (silent = false) ->
    @select_item(item) for item in @list.items
    @list.trigger('selected', @selected()) if @selected().length and not silent


  # Return selected items
  # @returns [Array]

  selected: () ->
    unless @_selected?
      @_selected = @list.where(__selected__: true)
    @_selected

  selected_item: ()->
    _ref = @list.selected()
    if _ref.length then _ref[0] else null

  selected_records: ->
    @list.selected().map((item)->item.record)

  selected_record: ->
    _ref = @list.selected_records()
    if _ref.length then _ref[0] else null

  selected_size: ->
    @list.selected().length
