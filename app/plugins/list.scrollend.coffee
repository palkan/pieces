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
      @scroll_listener = if @list.options.scroll_object == 'window' then $(window) else @list.items_cont
      @list.scroll_end = this
      
      @_prev_top = @scroll_object.scrollTop()

      @_scroll_listener = debounce 500, (event) =>
        if @_prev_top < @scroll_object.scrollTop() and @scroll_object.scrollHeight() - @scroll_object.scrollTop() - @scroll_object.height()  < 50
          @list.trigger 'scroll_end'
          
      @enable() unless @list.options.scroll_end is false


      return

    enable: () ->
      @scroll_listener.on 'scroll', @_scroll_listener 

    disable: () ->
      @scroll_listener.off 'scroll', @_scroll_listener      
