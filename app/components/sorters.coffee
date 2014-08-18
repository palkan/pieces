'use strict'
pi = require '../core'
require './pieces'
utils = pi.utils

_sort_param = (name,order) ->
  ref = {}
  ref[name] = order
  ref

# Contain logic to support list sorting
class pi.Sorters extends pi.Base
  @requires 'sorters'

  postinitialize: ->
    super     
    
    @sorters_by_name = {}
    @_value = []

    for sorter in @sorters
      @sorters_by_name[sorter.options.name] = sorter
      if sorter.hasClass('is-desc')
        @update_sorter sorter, 'desc'
      else if sorter.hasClass('is-asc')
        @update_sorter sorter, 'asc'
      
    @on 'click', @sorter_click(), @, (e) => e.target.host is @

  sorter_click: () ->
    @_sorter_click ||= (e) =>
      _old = e.target.__state__
      @clear() unless @options.multiple
      @toggle_state e.target, _old 
      @trigger 'update', @value()

  toggle_state: (sorter, prev_state) ->
    switch 
      when prev_state is 'asc' then @update_sorter(sorter,'desc')
      when (prev_state is 'desc' and @options.multiple) then @remove_sorter(sorter)
      else @update_sorter(sorter,'asc')
    return

  update_sorter: (sorter, new_state) ->
    sorter.__state__ = new_state
    sorter.removeClass 'is-desc', 'is-asc'
    sorter.addClass "is-#{new_state}"
    
    if (val = @_find_param(sorter.options.name))
      for own key,_ of val # TODO: fucking shit!
        val[key] = sorter.__state__
    else
      @_value.push(_sort_param(sorter.options.name, sorter.__state__))

    return

  remove_sorter: (sorter) ->
    if (val = @_find_param(sorter.options.name))
      @_value.splice(@_value.indexOf(val),1)
      sorter.__state__ = ''
      sorter.removeClass 'is-desc', 'is-asc'
    return

  _find_param: (name) ->
    for val in @_value
      for own key,_ of val
        return val if key is name
    return         

  value: ->
    @_value

  set: (sort_params) ->
    @clear()
    for param in sort_params
      for own name,val of param
        @update_sorter(@sorters_by_name[name], val)
    return

  clear: ->
    @_value.length = 0
    for sorter in @sorters
      sorter.__state__ = ''
      sorter.removeClass 'is-desc', 'is-asc'
    @

pi.Guesser.rules_for 'sorters', ['pi-sorters'], null
