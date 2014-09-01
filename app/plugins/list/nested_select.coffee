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

    @selectable = @list.selectable || {select_all: _null, clear_selection: _null} 
    @list.delegate_to @, 'clear_selection', 'select_all', 'selected'

    @type @list.options.nested_select_type||""

    @list.on 'selection_cleared,selected', (e) =>
      if e.target != @list
        e.cancel()
        @_check_selected()
    return

  _check_selected: pi.List.Selectable::_check_selected

  type: (value) ->
    @is_radio = !!value.match('radio')

  clear_selection: (silent = false) ->
    @selectable.clear_selection()
    for item in @list.find_cut('.pi-list')
      item._nod.clear_selection?()          
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
