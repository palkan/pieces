do (context = this) ->
  "use strict"
  # shortcuts
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  class pi.FileInput extends pi.BaseInput
    initialize: ->
      super
      @files = []

    postinitialize: ->
      super
      @input.on 'change', =>
        if @input.node.files.length
          @files.length = 0
          @files.push(file) for file in @input.node.files
          @trigger 'files_selected', @files
        else
          @clear()
    multiple: (value) ->
      if value
        @input.attr 'multiple',''
      else
        @input.attr 'multiple',null
    
    clear: ->
      super
      @files.length = 0

    files: ->
      @files

  pi.Guesser.rules_for 'file_input', ['pi-file-input-wrap'], 'input[file]', (nod) -> nod.children("input[type=file]").length is 1