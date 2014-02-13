do (context = this) ->
  "use strict"
  # shortcuts
  $ = context.jQuery
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  # [Plugin]
  # Dispatch 'autoload' event when list is scrolled to bottom
  #

  class pi.Autoload
    constructor: (@list) ->
      @scroll_object = if @list.options.scroll_object == 'window' then $(document.body) else @list.items_cont
      @list.autoload = this
      
      @_prev_top = @scroll_object[0].scrollTop

      @_wait = false

      @_scroll_listener = (event) =>
        utils.debug 'scroll'
        if not @_wait and @_prev_top < @scroll_object[0].scrollTop and @scroll_object[0].scrollHeight - @scroll_object[0].scrollTop - @scroll_object[0].clientHeight  < 50
          utils.debug 'autoload'
          @list.trigger 'autoload'
          @_wait = true
          after 500, => 
            @_wait = false 

      @enable() unless @list.options.autoload is false


      return

    enable: () ->
      @scroll_object.on 'scroll', @_scroll_listener 

    disable: () ->
      @scroll_object.off 'scroll', @_scroll_listener      
