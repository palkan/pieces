'use strict'
pi = require '../pi'
require '../utils'
require './events'

utils = pi.utils

#Events = pi.Events || {}

class pi.NodEvent extends pi.Event

  @aliases: {}
  @reversed_aliases: {}
  @delegates: {}

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

  @register_delegate: (type, delegate) ->
    @delegates[type] = delegate

  @has_delegate: (type) ->
    !!@delegates[type]

  @register_alias: (from, to) ->
    @aliases[from] = to
    @reversed_aliases[to] = from

  @has_alias: (type) ->
    !!@aliases[type]

  @is_aliased: (type) ->
    !!@reversed_aliases[type]

  constructor: (event) ->
    @event = event || window.event  

    @origTarget = @event.target || @event.srcElement
    @target = pi.Nod.create @origTarget
    @type = if @constructor.is_aliased(event.type) then @constructor.reversed_aliases[event.type] else event.type
    @ctrlKey = @event.ctrlKey
    @shiftKey = @event.shiftKey
    @altKey = @event.altKey
    @metaKey = @event.metaKey
    @detail = @event.detail
    @bubbles = @event.bubbles

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

NodEvent = pi.NodEvent

_mouse_regexp = /(click|mouse|contextmenu)/i

_key_regexp = /(keyup|keydown|keypress)/i

class pi.MouseEvent extends NodEvent
  constructor: ->
    super
    
    @button = @event.button

    unless @pageX?
      @pageX = @event.clientX + document.body.scrollLeft + document.documentElement.scrollLeft 
      @pageY = @event.clientY + document.body.scrollTop + document.documentElement.scrollTop

    unless @offsetX?
      @offsetX = @event.layerX - @origTarget.offsetLeft
      @offsetY = @event.layerY - @origTarget.offsetTop

    @wheelDelta = @event.wheelDelta
    unless @wheelDelta?
      @wheelDelta = -@event.detail*40

class pi.KeyEvent extends NodEvent
  constructor: ->
    super      
    @keyCode = @event.keyCode || @event.which
    @charCode = @event.charCode

  
_prepare_event = (e) ->
  if _mouse_regexp.test e.type
    new pi.MouseEvent e
  else if _key_regexp.test e.type
    new pi.KeyEvent e
  else
    new NodEvent e

_selector_regexp = /[\.#]/

_selector = (s, parent) ->
  ## when selector is tag (for links default behaviour preventing)
  unless _selector_regexp.test s
    (e) ->
      return e.target.node.matches(s)
  else
    (e) ->
      parent ||= document
      node = e.target.node
      return true if node.matches(s) 
      return false if node is parent
      while((node = node.parentNode) and node != parent)
        return (e.target = pi.Nod.create(node)) if node.matches(s)

class pi.NodEventDispatcher extends pi.EventDispatcher

  constructor: ->
    super
    @native_event_listener = (event) => 
      @trigger _prepare_event(event)  

  listen: (selector, event, callback, context) ->
    @on event, callback, context, _selector(selector, @node)

  add_native_listener: (type) ->
    if NodEvent.has_delegate type
      NodEvent.delegates[type].add @, @native_event_listener
    else 
      NodEvent.add @node, type, @native_event_listener 

  remove_native_listener: (type) ->
    if NodEvent.has_delegate type
      NodEvent.delegates[type].remove @
    else
      NodEvent.remove @node, type, @native_event_listener


  add_listener: (listener) ->
    if !@listeners[listener.type]
      @add_native_listener listener.type
      @add_native_listener NodEvent.aliases[listener.type] if NodEvent.has_alias(listener.type)
    super

  remove_type: (type) ->
    @remove_native_listener type
    @remove_native_listener NodEvent.aliases[type] if NodEvent.has_alias(type)
    super

  remove_all: ->
    for own type,list of @listeners
      do =>
        @remove_native_listener type
        @remove_native_listener NodEvent.aliases[type] if NodEvent.has_alias(type)
    super