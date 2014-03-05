do (context = this) ->
  "use strict"
  # shortcuts
  $ = context.jQuery
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  class pi.TextInput extends pi.Base
    initialize: ->
      @input = if @nod.get(0).nodeName.toLowerCase() is 'input' then @nod else @nod.find('input')
      @editable = true
      make_readonly if @options.readonly
      super

    make_editable: () ->
      if not @editable
        @input.get(0).removeAttribute('readonly') 
        @nod.removeClass 'is-readonly'
        @editable = true
        @changed 'editable'
      return

    make_readonly: () ->
      if @editable
        @input.get(0).setAttribute('readonly', 'readonly')
        @nod.addClass 'is-readonly'
        @editable = false
        @changed 'editable'
      return        

    value: (val = null) ->
      if val?
        @input.val(val)
      @input.val()

    clear: () ->
      @input.val ''