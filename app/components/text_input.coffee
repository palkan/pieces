'use strict'
Base = require './base'
Events = require './events'
utils = require '../core/utils'
BaseInput = require './base_input'
Klass = require './utils/klass'

class TextInput extends BaseInput
  postinitialize: ->
    super
    @editable = true
    @readonly() if (@options.readonly || @hasClass(Klass.READONLY))
    @input.on 'change', (e) =>
      e.cancel()
      @trigger Events.InputEvent.Change, @value()

    @input.on 'input', (e) =>
      e.cancel()
      @val = @value()
      @trigger Events.InputEvent.Input, @val


  @active_property @::, 'editable',
    type: 'bool',
    default: true,
    event: Events.InputEvent.Editable
    class:
      name: Klass.READONLY
      on: false
    node_attr: 
      name: 'readonly'
      on: false

  readonly: (val = true) ->
    @editable = !val

module.exports = TextInput
