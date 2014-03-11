do (context = this) ->
  "use strict"
  # shortcuts
  $ = context.jQuery
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  class pi.TextArea extends pi.TextInput
    initialize: ->
      @input = if @nod.get(0).nodeName.toLowerCase() is 'textarea' then @nod else @nod.find('textarea')
      @editable = true
      @make_readonly() if (@options.readonly || @nod.hasClass('is-readonly'))
      pi.Base::initialize.apply(this)
      @enable_autosize() if @options.autosize is true

    autosizer: ->
      @_autosizer ||= =>
        @input.css('height', @input.get(0).scrollHeight)

    enable_autosize: ->
      return if @_autosizing

      @input.on 'change', @autosizer()
      @_autosizing = true
      @autosizer()()

    disable_autosize: ->
      return unless @_autosizing

      @input.css height: ''
      @input.off 'change', @autosizer()
      @_autosizing = false