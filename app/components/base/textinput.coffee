do (context = this) ->
  "use strict"
  # shortcuts
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  class pi.TextInput extends pi.BaseInput
    postinitialize: ->
      super
      @editable = true
      @readonly() if (@options.readonly || @hasClass('is-readonly'))

    edit: () ->
      unless @editable
        @input.attr 'readonly', null 
        @removeClass 'is-readonly'
        @editable = true
        @trigger 'editable', true
      @

    readonly: () ->
      if @editable
        @input.attr('readonly', 'readonly')
        @addClass 'is-readonly'
        @editable = false
        @blur()
        @trigger 'editable', false
      @        

  pi.Guesser.rules_for 'text_input', ['text-input'], ['input[text]']