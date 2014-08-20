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
    @__selected__ = false
    @select() if (@options.selected || @hasClass('is-selected') || (@value()|0))
    @on 'click', (e) =>
      e.cancel()
      @toggle_select()

  select: (silent = false) ->
    unless @__selected__
      @addClass 'is-selected'
      @__selected__ = true
      @input.value 1
      @trigger('update', true) unless silent

  deselect: (silent = false) ->
    if @__selected__
      @removeClass 'is-selected'
      @__selected__ = false
      @input.value 0
      @trigger('update', false) unless silent


  toggle_select: (silent) ->
    if @__selected__
      @deselect(silent)
    else
      @select(silent)

  value: (val) ->
    if val?
      super
      @__selected__ = !val
      @toggle_select()
    else
      super

  clear: ->
    @removeClass 'is-selected'
    @__selected__ = false
    super

pi.Guesser.rules_for 'checkbox', ['pi-checkbox-wrap'], null