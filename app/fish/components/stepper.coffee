'use strict'
pi = require '../../core'
require '../../components/base/base_input'
require '../../components/events/input_events'
utils = pi.utils

class pi.Stepper extends pi.TextInput
  postinitialize: ->
    super
    @_prefix = if @options.prefix? then @options.prefix else ""
    @_suffix = if @options.suffix? then @options.suffix else ""
    
    @_step = parseFloat(@options.step || 1)
    @_min = parseFloat(@options.min) if @options.min?
    @_max = parseFloat(@options.max) if @options.max?

    @value @input.value()

    @listen '.step', 'click', (e) =>
      if e.target.hasClass('step-up')
        @incr()
      else
        @decr()
      @trigger pi.InputEvent.Change, @value()
      e.cancel()

  value: (val) ->
    if val?
      
      if @_max? and (val|0) > @_max
        val = @_max
      else if @_min? and (val|0) < @_min
        val = @_min

      super @_prepare_value(val)
    else
      @_read_value()

  incr: ->
    @value ((@_read_value()|0) + @_step)

  decr: ->
    @value ((@_read_value()|0) - @_step)

  _prepare_value: (val) -> 
    if val is null
      return null
    "#{@_prefix}#{val}#{@_suffix}"

  _read_value: ->
    val = @input.node.value
    val.replace(@_prefix,'').replace(@_suffix,'')

pi.Guesser.rules_for 'stepper', ['pi-stepper']