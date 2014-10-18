'use strict'
pi = require '../../core'
require '../../components/base/base_input'
require '../../components/events/input_events'
utils = pi.utils

_name_reg = /([^\/\\]+$)/
_true = -> true

class pi.FileInput extends pi.BaseInput
  initialize: ->
    super
    @_files = []

  postinitialize: ->
    super
    @multiple !!@options.multiple
    @accept @options.accept

    if @options.rxp?
      _rxp = new RegExp(@options.rxp, 'i')
      @_filter = (file) ->
        _rxp.test(file.name)
    else
      @_filter = _true

    # remove focus from input
    @input.attr('tabindex','-1')

    @input.on 'change', (e) =>
      e.cancel()
      @_files.length = 0
      # <IE9 hack
      unless @input.node.files?
        if @input.node.value
          f = {name: @input.node.value.split(_name_reg)[1]}
          if @_filter(f) is true
            @_files.push f
            @trigger pi.InputEvent.Change, @value() 
        return
      if @input.node.files.length
        @_files.push(file) for file in @input.node.files when @_filter(file)
        @trigger(pi.InputEvent.Change, @value()) if @_files.length
      else
        @clear()

  multiple: (value) ->
    @_multiple = value
    if value
      @input.attr 'multiple',''
    else
      @input.attr 'multiple',null

  accept: (value) ->
    @_accept = value
    if value
      @input.attr 'accept', value
    else
      @input.attr 'accept', null
  
  clear: ->
    @_files.length = 0
    super

  value: ->
    if @_multiple
      @_files
    else
      @_files[0]