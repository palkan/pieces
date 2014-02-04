class pi.TextInput extends pi.Base
  initialize: ->
    @editable = true
    make_readonly if @options.readonly
    super

  make_editable: () ->
    if not @editable
      @nod.get(0).removeAttribute('readonly') 
      @nod.removeClass 'readonly'
      @editable = true
      @changed 'editable'
    return

  make_readonly: () ->
    if @editable
      @nod.get(0).setAttribute('readonly', 'readonly')
      @nod.addClass 'readonly'
      @editable = false
      @changed 'editable'
    return        
