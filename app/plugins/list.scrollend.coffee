do (context = this) ->
  "use strict"
  # shortcuts
  $ = context.jQuery
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  # [Plugin]
  # Dispatch 'scroll_end' event when list is scrolled to bottom
  #

  class pi.ScrollEnd
    constructor: (@list) ->
      @scroll_object = if @list.options.scroll_object == 'window' then document.documentElement else @list.items_cont.get(0)
      @scroll_listener = if @list.options.scroll_object == 'window' then $(window) else @list.items_cont
      @list.scroll_end = this
      
      @_prev_top = @scroll_object.scrollTop

      @_wait = false

      @_scroll_listener = (event) =>
        if not @_wait and @_prev_top < @scroll_object.scrollTop and @scroll_object.scrollHeight - @scroll_object.scrollTop - @scroll_object.clientHeight  < 50
          @list.trigger 'scroll_end'
          @_wait = true
          after 500, => 
            @_wait = false 

      @enable() unless @list.options.scroll_end is false


      return

    enable: () ->
      @scroll_listener.on 'scroll', @_scroll_listener 

    disable: () ->
      @scroll_listener.off 'scroll', @_scroll_listener      
