do (context = this) ->
  "use strict"
  # shortcuts
  $ = context.jQuery
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  # [Plugin]
  # Dispatch 'scroll_end' event when list is scrolled to bottom
  #

  _document =
    scrollTop: ->
      $(window).scrollTop()
    scrollHeight: ->
      document.documentElement.scrollHeight
    height: ->
      $(window).height()

  class pi.ScrollEnd
    constructor: (@list) ->

      @scroll_object = if @list.options.scroll_object == 'window' then _document else @list.items_cont
      @scroll_native_listener = if @list.options.scroll_object == 'window' then $(window) else @list.items_cont
      @list.scroll_end = this

      @_prev_top = @scroll_object.scrollTop()

      @enable() unless @list.options.scroll_end is false
      return

    enable: () ->
      return if @enabled

      @scroll_native_listener.on 'scroll', @scroll_listener() 
      @enabled = true

    disable: () ->
      return unless @enabled
      @scroll_native_listener.off 'scroll', @scroll_listener()
      @_scroll_listener = null      
      @enabled = false

    scroll_listener: () ->
      return @_scroll_listener if @_scroll_listener?
      @_scroll_listener = debounce 500, (event) =>
        if @_prev_top <= @scroll_object.scrollTop() and @list.height() - @scroll_object.scrollTop() - @scroll_object.height()  < 50
          @list.trigger 'scroll_end'
        @_prev_top = @scroll_object.scrollTop()