'use strict'
pi = require '../core'
require './base/base_input'
require './events/input_events'
require './base/list'
utils = pi.utils

class pi.RadioGroup extends pi.BaseInput
  @include pi.List
  @include_plugins pi.List.Selectable
  
  postinitialize: ->
    pi.List::postinitialize.call(@)
    @selectable.type 'radio'
    @clear_selection(true)
    
    # we need real input (hidden)
    @input = @find('input')
    
    @value @input.value()

    @on 'selected', (e) =>
      e.cancel()
      @input.value e.data[0].record.value
      @trigger pi.InputEvent.Change, @value()

  value: (val) ->
    if val?
      val = utils.serialize val
      ref = @where(record: {value: val})
      if ref.length
        @input.value val
        @select_item ref[0]
    else
      @input.value()

  clear: (silent = false) ->
    @clear_selection(true)
    @input.value ''
    @trigger(pi.InputEvent.Clear) unless silent

pi.Guesser.rules_for 'radio_group', ['pi-radio-group']
