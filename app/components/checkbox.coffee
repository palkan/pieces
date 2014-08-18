'use strict'
pi = require '../core'
require './base/base_input'
utils = pi.utils
# checkbox should have structure
# div.checkbox
# -> label ...
# -> input type="hidden"

class pi.Checkbox extends pi.BaseInput
  postinitialize: ->
    super
    @attr('tabindex',0)
    @selected = false
    @select() if (@options.selected || @hasClass('is-selected') || (@value()|0))
    @on 'click', =>
      @toggle_select()

  select: ->
    unless @selected
      @addClass 'is-selected'
      @selected = true
      @input.value 1
      @trigger 'selected', true

  deselect: ->
    if @selected
      @removeClass 'is-selected'
      @selected = false
      @input.value 0
      @trigger 'selected', false


  toggle_select: ->
    if @selected
      @deselect()
    else
      @select()

pi.Guesser.rules_for 'checkbox', ['pi-checkbox-wrap'], null