'use strict'
Base = require './base'
Events = require './events'
utils = require '../core/utils'

_pass = (val) -> val
_serialize = (val) -> utils.serialize(val)

class BaseInput extends Base
  postinitialize: ->
    @input ||= if @node.nodeName is 'INPUT' then @ else @find('input')
    if @options.serialize is true
      @_serializer = _serialize
    else
      @_serializer = _pass

    if @options.default_value? and !utils.serialize(@value())
      @value @options.default_value

  # bindable property
  @active_property @::, 'val', default: ''

  value: (val) ->
    if val? 
      @input.node.value=val
      @val = @_serializer val
      @
    else
      @_serializer @input.node.value

  clear: (silent = false) ->
    if @options.default_value?
      @value @options.default_value
    else
      @value ''
    @trigger(Events.InputEvent.Clear) unless silent

module.exports = BaseInput
