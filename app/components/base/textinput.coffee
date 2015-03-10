'use strict'
pi = require '../../core'
require './base'
require './base_input'
require '../events/input_events'
utils = pi.utils

class pi.TextInput extends pi.BaseInput
  postinitialize: ->
    super
    @editable = true
    @readonly() if (@options.readonly || @hasClass(pi.klass.READONLY))
    @input.on 'change', (e) =>
      e.cancel()
      @trigger pi.InputEvent.Change, @value()

  @active_property 'editable',
    type: 'bool',
    default: true,
    event: pi.InputEvent.Editable
    class:
      name: pi.klass.READONLY
      on: false
    node_attr: 
      name: 'readonly'
      on: false

  readonly: (val = true) ->
    @editable = !val

module.exports = pi.TextInput
