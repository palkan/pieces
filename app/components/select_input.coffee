'use strict'
pi = require '../core'
require './base/base_input'
require './events/input_events'
utils = pi.utils

# Select input is based on hidden input element and use simple list as options list

class pi.SelectInput extends pi.BaseInput
  @requires 'dropdown', 'placeholder'

  postinitialize: ->
    super      
    @attr('tabindex','0')

    # ensure dropdown is selectable and radio list
    unless @dropdown.has_selectable
      @dropdown.attach_plugin pi.List.Selectable

    @dropdown.selectable.type('radio')

    @dropdown.on 'selected', (e) =>
      @value e.data[0].record.value
      @placeholder.text e.data[0].text()
      @trigger pi.InputEvent.Change, e.data[0].record.value
      @blur()

    @on 'focus', =>
      @dropdown.show()

    @on 'blur', =>
      @dropdown.hide()

    if @input.value()
      @value utils.serialize(@input.value())
    else if @options.default_value?
      @value @options.default_value
    else if @placeholder.text() is ''
      @placeholder.text(@placeholder.options.placeholder)

  value: (val) ->
    if val?
      super
      @dropdown.clear_selection(true)
      ref = @dropdown.where(record: {value: val})
      if ref.length
        item = ref[0]
        @dropdown.select_item item
        @placeholder.text item.text()
      val
    else
      super

  clear: ->
    @dropdown.clear_selection(true)
    if @options.default_value?
      @value @options.default_value
    else
      @placeholder.text(@placeholder.options.placeholder)
      super

pi.Guesser.rules_for 'select_input', ['pi-select-field'], null
