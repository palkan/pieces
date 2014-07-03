do (context = this) ->
  "use strict"

  # shortcuts
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  # Extend Nod
   
  class pi.Event
    constructor: (event) ->
      if event? and typeof event is "object"
        utils.extend @, event
      else 
        @type = event

      @canceled = false

    cancel: ->
      @canceled = true


  _true = -> true

  # Event listener class
  # @private

  class pi.EventListener
    constructor: (@type, @handler, @context = null, @disposable = false, @conditions) ->
      @handler._uuid = "fun"+utils.uuid() if not @handler._uuid?
      @uuid = "#{@type}:#{@handler._uuid}"

      unless typeof @conditions is 'function'
        @conditions = _true

      if @context?
        @context._uuid = "obj"+utils.uuid() if not @context._uuid?
        @uuid+=":#{@context._uuid}"
      
    dispatch: (event) ->
      if @disposed or !@conditions(event)
        return

      @handler.call(@context,event)
      @dispose() if @disposable

    dispose: () ->
      @handler = @context = @conditions = null 
      @disposed = true


  _types = (types) ->
    if typeof types is 'string'
      types.split ','
    else if Array.isArray(types)
      types
    else
      [null]

  # Base Event Dispatcher class for all components
  # Wrapper for underlying native events api (jQuery) and custom events
  # @private

  class pi.EventDispatcher
    constructor: ->
      @listeners = {} # event_type to listener hash
      @listeners_by_key = {} # key is event_type:handler_uuid:context_uuid

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

    trigger: (event, data) ->
      event = new pi.Event(event) unless event instanceof pi.Event
      event.data = data if data?
      event.currentTarget = this
      if @listeners[event.type]?
        utils.debug "Event: #{event.type}"
        for listener in @listeners[event.type]
          listener.dispatch event
          break if event.canceled is true
        @remove_disposed_listeners()
      return

    ## internal

    add_listener: (listener) ->
      @listeners[listener.type] ||= []
      @listeners[listener.type].push listener
      @listeners_by_key[listener.uuid] = listener

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

      uuid = "#{type}:#{callback._uuid}"

      if context?
        uuid+=":#{context._uuid}"

      listener = @listeners_by_key[uuid]

      if listener?
        delete @listeners_by_key[uuid]
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