pi = require 'core'
require './base/base_input'
utils = pi.utils

# Select input is based on hidden input element and use simple list as options list

class pi.SelectInput extends pi.BaseInput
  @requires 'dropdown'

  postinitialize: ->
    super      
    @attr('tabindex','0')

    # ensure dropodown is selectable and radio list
    unless @dropdown.has_selectable
      @dropdown.attach_plugin pi.List.Selectable

    @dropdown.selectable.type('radio')

    @dropdown.on 'selected', (e) =>
      @value e.data[0].record.value
      @trigger 'change', e.data[0].record

    @on 'focus', =>
      @dropdown.show()

    @on 'blur', =>
      @dropdown.hide()

pi.Guesser.rules_for 'select_input', ['pi-select-field'], null
