pi = require 'core'
require './base/base_input'
utils = pi.utils

_name_reg = /([^\/\\]+$)/

class pi.FileInput extends pi.BaseInput
  initialize: ->
    super
    @_files = []

  postinitialize: ->
    super
    # remove focus from input
    @input.attr('tabindex','-1')

    @input.on 'change', =>
      @_files.length = 0
      # <IE9 hack
      unless @input.node.files?
        if @input.node.value
          @_files.push {name: @input.node.value.split(_name_reg)[1]}
          @trigger('files_selected',@_files) 
        return
      if @input.node.files.length
        @_files.push(file) for file in @input.node.files
        @trigger 'files_selected', @_files
      else
        @clear()
  multiple: (value) ->
    if value
      @input.attr 'multiple',''
    else
      @input.attr 'multiple',null
  
  clear: ->
    super
    @_files.length = 0

  files: ->
    @_files

pi.Guesser.rules_for 'file_input', ['pi-file-input-wrap'], ['input[file]'], (nod) -> nod.children("input[type=file]").length is 1