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
      @attr('multiple','') if @options.multiple
      @input.on 'change', =>
        if @input.node.files.length
          @files.push(file) for file in @input.node.files
          @trigger 'files_selected', @files

    clear: ->
      super
      @files.length = 0

    files: ->
      @files

  pi.Guesser.rules_for 'file_input', ['file-input'], 'input[file]'