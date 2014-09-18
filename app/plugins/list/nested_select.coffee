'use strict'
pi = require '../../core'
require '../../components/base/list'
require '../plugin'
require './selectable'
utils = pi.utils

# [Plugin]
# Add ability to 'select' elements within list and sublists
# All sublists should have class 'pi-list'

_null = ->

class pi.List.NestedSelect extends pi.Plugin
  id: 'nested_select'
  initialize: (@list) ->
    super

    @selectable = @list.selectable || {select_all: _null, clear_selection: _null, type: _null, _selected_item: null} 
    @list.delegate_to @, 'clear_selection', 'select_all', 'selected'

    @type @list.options.nested_select_type||""

    @list.on 'selection_cleared,selected', (e) =>
      if @_watching_radio and e.type is 'selected' 
          if e.target is @list
            item = @selectable._selected_item
          else
            item = e.data[0].host.selectable._selected_item
          @update_radio_selection item
      if e.target != @list
        e.cancel()
        @_check_selected()
    return

  _check_selected: pi.List.Selectable::_check_selected

  type: (value) ->
    @is_radio = !!value.match('radio')
    if @is_radio 
      @enable_radio_watch()
    else
      @disable_radio_watch()

  enable_radio_watch: ->
    @_watching_radio = true

  disable_radio_watch: ->
    @_watching_radio = false


  update_radio_selection: (item) ->
    return if not item or (@_prev_selected_list is item.host)
    @_prev_selected_list = item.host
    if @list.selected_size()>1
      @list.clear_selection(true)
      item.host.select_item item
      return

  clear_selection: (silent = false) ->
    @selectable.clear_selection(silent)
    for item in @list.find_cut('.pi-list')
      item._nod.clear_selection?(silent)          
    @list.trigger('selection_cleared') unless silent
  
  select_all: () ->
    @selectable.select_all(true)
    for item in @list.find_cut('.pi-list')
      item._nod.select_all?(true)         

    _selected = @selected() 
    @list.trigger('selected', _selected) if _selected.length

  selected: () ->
    _selected = []
    for item in @list.items
      if item.__selected__
        _selected.push item
      if item instanceof pi.List
        _selected = _selected.concat (item.selected?()||[])
      else if (sublist = item.find('.pi-list'))
        _selected = _selected.concat (sublist.selected?()||[])
    _selected
