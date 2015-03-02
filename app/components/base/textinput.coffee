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

  edit: () ->
    unless @editable
      @input.attr 'readonly', null 
      @removeClass pi.klass.READONLY
      @editable = true
      @trigger pi.InputEvent.Editable, true
    @

  readonly: () ->
    if @editable
      @input.attr('readonly', 'readonly')
      @addClass pi.klass.READONLY
      @editable = false
      @blur()
      @trigger pi.InputEvent.Editable, false
    @

module.exports = pi.TextInput
