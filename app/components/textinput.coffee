do (context = this) ->
  "use strict"
  # shortcuts
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  class pi.TextInput extends pi.Base

    initialize: ->
      @input = if @node.nodeName is 'INPUT' then @ else @find('input')
      @editable = true
      @make_readonly() if (@options.readonly || @hasClass('is-readonly'))
      super

    make_editable: () ->
      unless @editable
        @input.attr('readonly',null) 
        @removeClass 'is-readonly'
        @editable = true
        @trigger 'editable'
      @

    make_readonly: () ->
      if @editable
        @input.attr('readonly', 'readonly')
        @addClass 'is-readonly'
        @editable = false
        @trigger 'readonly'
      @        

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