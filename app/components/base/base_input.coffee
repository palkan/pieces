'use strict'
pi = require '../../core'
require '../pieces'
require '../events/input_events'
utils = pi.utils

_pass = (val) -> val
_serialize = (val) -> utils.serialize(val)

class pi.BaseInput extends pi.Base
  postinitialize: ->
    @input ||= if @node.nodeName is 'INPUT' then @ else @find('input')
    if @options.serialize is true
      @_serializer = _serialize
    else
      @_serializer = _pass

    if @options.default_value? and !utils.serialize(@value())
      @value @options.default_value

  value: (val) ->
    if val? 
      @input.node.value=val
      @
    else
      @_serializer @input.node.value

  clear: (silent = false) ->
    if @options.default_value?
      @value @options.default_value
    else
      @value ''
    @trigger(pi.InputEvent.Clear) unless silent