do (context = this) ->
  "use strict"
  # shortcuts
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  class pi.BaseInput extends pi.Base

    postinitialize: ->
      @input = if @node.nodeName is 'INPUT' then @ else @find('input')
    
    value: (val) ->
      if @ is @input
        super
      else
        if val? 
          @input.node.value=val
          @
        else
          @input.node.value

    clear: () ->
      @input.value ''

  pi.Guesser.rules_for 'text_input', ['text-input'], ['input[text]']