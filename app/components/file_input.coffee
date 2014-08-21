'use strict'
pi = require '../core'
require './base/base_input'
require './events/input_events'
utils = pi.utils

_name_reg = /([^\/\\]+$)/

class pi.FileInput extends pi.BaseInput
  initialize: ->
    super
    @_files = []

  postinitialize: ->
    super
    @_multiple = !!@input.attr('multiple')
    # remove focus from input
    @input.attr('tabindex','-1')

    @input.on 'change', (e) =>
      e.cancel()
      @_files.length = 0
      # <IE9 hack
      unless @input.node.files?
        if @input.node.value
          @_files.push {name: @input.node.value.split(_name_reg)[1]}
          @trigger pi.InputEvent.Change, @value() 
        return
      if @input.node.files.length
        @_files.push(file) for file in @input.node.files
        @trigger pi.InputEvent.Change, @value()
      else
        @clear()

  multiple: (value) ->
    @_multiple = value
    if value
      @input.attr 'multiple',''
    else
      @input.attr 'multiple',null
  
  clear: ->
    @_files.length = 0
    super

  value: ->
    if @_multiple
      @_files
    else
      @_files[0]

pi.Guesser.rules_for 'file_input', ['pi-file-input-wrap'], ['input[file]'], (nod) -> nod.children("input[type=file]").length is 1