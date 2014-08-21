'use strict'
pi = require '../../core'
require '../pieces'
require './base_input'
require '../events/input_events'
utils = pi.utils

class pi.TextInput extends pi.BaseInput
  postinitialize: ->
    super
    @editable = true
    @readonly() if (@options.readonly || @hasClass('is-readonly'))
    @input.on 'change', (e) =>
      e.cancel()
      @trigger pi.InputEvent.Change, @value()

  edit: () ->
    unless @editable
      @input.attr 'readonly', null 
      @removeClass 'is-readonly'
      @editable = true
      @trigger pi.InputEvent.Editable, true
    @

  readonly: () ->
    if @editable
      @input.attr('readonly', 'readonly')
      @addClass 'is-readonly'
      @editable = false
      @blur()
      @trigger pi.InputEvent.Editable, false
    @        

pi.Guesser.rules_for 'text_input', ['pi-text-input-wrap'], ['input[text]']