do (context = this) ->
  "use strict"

  # shortcuts
  pi = context.pi  = context.pi || {}
  utils = pi.utils
  Events = pi.Events || {}

  class pi.NodEvent extends pi.Event

    @aliases: 
      mousewheel: "DOMMouseScroll"

    @reversed_aliases:
      "DOMMouseScroll": "mousewheel"

    @add: ( -> 
      if typeof Element::addEventListener is "undefined" 
        (nod, event, handler) ->  
          nod.attachEvent("on" + event, handler)
      else
        (nod, event, handler) ->
          nod.addEventListener(event, handler)
      )()

    @remove: ( -> 
      if typeof Element::removeEventListener is "undefined" 
        (nod, event, handler) ->  
          nod.detachEvent("on" + event, handler)
      else            (nod, event, handler) ->
          nod.removeEventListener(event, handler)
      )()

    constructor: (event) ->
      @event = event || window.event  

      @target = @event.target || @event.srcElement
      @type = @constructor.reversed_aliases[event.type] || event.type
      @ctrlKey = @event.ctrlKey
      @shiftKey = @event.shiftKey
      @altKey = @event.altKey
      @metaKey = @event.metaKey
      @detail = @event.detail

    stopPropagation: ->
      if @event.stopPropagation 
        @event.stopPropagation()
      else
        @event.cancelBubble = true

    stopImmediatePropagation: ->
      if @event.stopImmediatePropagation 
        @event.stopImmediatePropagation()
      else
        @event.cancelBubble = true
        @event.cancel = true

    preventDefault: ->
      if @event.preventDefault
        @event.preventDefault()
      else
        @event.returnValue = false

    cancel: ->
      @stopImmediatePropagation()
      @preventDefault()
      super


  _mouse_regexp = /(click|mouse|contextmenu)/i

  class pi.MouseEvent extends pi.NodEvent
    constructor: ->
      super
      
      @button = @event.button

      unless @pageX?
        @pageX = @event.clientX + document.body.scrollLeft + document.documentElement.scrollLeft 
        @pageY = @event.clientY + document.body.scrollTop + document.documentElement.scrollTop

      unless @offsetX?
        @offsetX = @event.layerX - @target.offsetLeft
        @offsetY = @event.layerY - @target.offsetTop

      @wheelDelta = @event.wheelDelta
      unless @wheelDelta?
        @wheelDelta = -@event.detail*40

    
  _prepare_event = (e) ->
    if _mouse_regexp.test e.type
      new pi.MouseEvent e
    else
      new pi.NodEvent e

  class pi.NodEventDispatcher extends pi.EventDispatcher

    constructor: ->
      super
      @native_event_listener = (event) => @trigger _prepare_event(event)  

    add_native_listener: (type) ->
      pi.NodEvent.add @node, type, @native_event_listener 

    remove_native_listener: (type) ->
      pi.NodEvent.remove @node, type, @native_event_listener

    add_listener: (listener) ->
      if !@listeners[listener.type]
        @add_native_listener listener.type
        @add_native_listener pi.NodEvent.aliases[listener.type] if pi.NodEvent.aliases[listener.type]
      super

    remove_type: (type) ->
      @remove_native_listener type
      @remove_native_listener pi.NodEvent.aliases[type] if pi.NodEvent.aliases[type]
      super

    remove_all: ->
      for own type,list of @listeners
        do ->
          @remove_native_listener type
          @remove_native_listener pi.NodEvent.aliases[type] if pi.NodEvent.aliases[type]
     
    