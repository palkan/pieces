'use strict'
pi = require '../pi'
utils = require '../utils'
require '../core'

# Base event class
class pi.Event extends pi.Core
  constructor: (event, @target, bubbles = true) ->
    if event? and typeof event is "object"
      utils.extend @, event
    else 
      @type = event

    @bubbles = bubbles
    @canceled = false
    @captured = false

  cancel: ->
    @canceled = true



_true = -> true

# Event listener class
# @private

class pi.EventListener extends pi.Core
  constructor: (@type, @handler, @context = null, @disposable = false, @conditions) ->
    super
    @handler._uid = "fun"+utils.uid() if not @handler._uid?
    @uid = "#{@type}:#{@handler._uid}"

    unless typeof @conditions is 'function'
      @conditions = _true

    if @context?
      @context._uid = "obj"+utils.uid() if not @context._uid?
      @uid+=":#{@context._uid}"
    
  dispatch: (event) ->
    if @disposed or !@conditions(event)
      return

    unless @handler.call(@context,event) is false
      event.captured = true
    @dispose() if @disposable

  dispose: () ->
    @handler = @context = @conditions = null 
    @disposed = true


_types = (types) ->
  if typeof types is 'string'
    types.split /\,\s*/
  else if Array.isArray(types)
    types
  else
    [null]

# Base Event Dispatcher class for all components
# Wrapper for underlying native events and custom events
# @private

class pi.EventDispatcher extends pi.Core
  listeners: ''
  listeners_by_key: ''
  constructor: ->
    super
    @listeners = {} # event_type to listener hash
    @listeners_by_key = {} # key is event_type:handler_uid:context_uid

  # Attach listener

  on: (types, callback, context, conditions) ->
    @add_listener(new pi.EventListener(type, callback, context, false, conditions)) for type in _types(types)
  
  # Attach disposable (= one-time) listener

  one: (type, callback, context, conditions) ->
    @add_listener new pi.EventListener(type, callback, context, true, conditions)

  # Remove listeners
  # 
  # @param [String, Null] event
  # @param [Function, Null] callback
  # @param [Object, Null] context
  # 
  # @example Remove all listeners for all events
  #     element.off()
  #
  # @example Remove all listeners of a type 'event'
  #     element.off('event')  
  # 

  off: (types, callback, context, conditions) ->
    @remove_listener(type, callback, context, conditions) for type in _types(types)


  # Trigger event
  # @params [String] event
  # @params [Object, Null] data data that will be passed with event as 'event.data'
  # @params [Boolean] bubbles 

  trigger: (event, data, bubbles = true) ->
    event = new pi.Event(event, @, bubbles) unless event instanceof pi.Event
    event.data = data if data?
    event.currentTarget = @
    if @listeners[event.type]?
      utils.debug_verbose "Event: #{event.type}", event
      for listener in @listeners[event.type]
        listener.dispatch event
        break if event.canceled is true
      @remove_disposed_listeners()
  
    unless event.captured is true
      @bubble_event(event) if event.bubbles
    return

  ## internal
  

  bubble_event: (event) ->
    # overwrite for custom events
    return

  add_listener: (listener) ->
    @listeners[listener.type] ||= []
    @listeners[listener.type].push listener
    @listeners_by_key[listener.uid] = listener

  remove_listener: (type, callback, context = null, conditions = null) ->
    if not type?
      return @remove_all()
    
    if not @listeners[type]?
      return

    if not callback?
      listener.dispose() for listener in @listeners[type]
      @remove_type type
      @remove_disposed_listeners()
      return

    uid = "#{type}:#{callback._uid}"

    if context?
      uid+=":#{context._uid}"

    listener = @listeners_by_key[uid]

    if listener?
      delete @listeners_by_key[uid]
      @remove_listener_from_list type, listener

    return

  remove_listener_from_list: (type, listener) ->
    if @listeners[type]? and @listeners[type].indexOf(listener)>-1
      @listeners[type] = @listeners[type].filter (item) -> item != listener
      @remove_type(type) if not @listeners[type].length

  remove_disposed_listeners: ->
    for key,listener of @listeners_by_key
      if listener.disposed
        @remove_listener_from_list listener.type, listener
        delete @listeners_by_key[key]
        
  remove_type: (type) ->
    delete @listeners[type]
  
  remove_all: ->
    @listeners = {}
    @listeners_by_key = {} 

module.exports = pi.EventDispatcher
