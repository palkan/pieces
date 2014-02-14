do (context = this) ->
  "use strict"

  $ = context.$
  pi = context.pi  = context.pi || {}
  pi.config ||= {}
  
  _email_regexp = /\b[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}\b/

  _uniq_id = 100

  _log_levels =
    error:
      color: "#dd0011"
      sort: 4
    debug:
      color: "#009922"
      sort: 0
    info:
      color: "#1122ff"
      sort: 1
    warning: 
      color: "#ffaa33"
      sort: 2

  _show_log =  (level) ->
    _log_levels[pi.log_level].sort <= _log_levels[level].sort

  _key_compare = (a,b,key,reverse) ->
    return 0 if a[key] == b[key]
    if a[key] < b[key]
      1+(-2*reverse)
    else 
      -(1+(-2*reverse))

  _keys_compare = (a,b,keys,reverse) ->
    r = 0
    for key, i in keys
      do (key,i) ->
        r_ = _key_compare(a,b,key,(if typeof reverse is 'object' then reverse[i] else reverse))
        r = r_ if r is 0
    return r


    
  pi.log_level = "info"

  pi.utils =
    log: (level, message) ->
      _show_log(level) && console.log("%c #{ pi.utils.now().format('HH:MM:ss:SSS') } [#{ level }]", "color: #{_log_levels[level].color}", message)

    jstime: (ts) ->
        ts *= 1000 if (ts < 10000000000)
        ts

    now: ->
      moment()

    uuid: ->
      ""+(++_uniq_id)

    #Escape regular expression characters (to use string in regexp)
    escapeRegexp: (str) -> 
        str.replace(/[-[\]{}()*+?.,\\^$|#]/g, "\\$&")

    
    is_email:(str) ->        
      _email_regexp.test(str.toLowerCase())


    camelCase: (string) ->
      string = string + ""
      if string.length then ((word[0].toUpperCase()+word.substring(1)) for word in string.split('_')).join('') else string

    snakeCase: (string) ->
      string = string + ""
      if string.length 
        matches = string.match(/((?:^[^A-Z]|[A-Z])[^A-Z]*)/g)
        (word.toLowerCase() for word in matches).join('_') 
      else 
        string
    

    serialize: (val) ->
      val = switch
        when not val? then null
        when val == 'true' then true
        when val == 'false' then false
        when isNaN(Number(val)) then val 
        else Number(val)

    clone: (obj) ->
      if not obj? or typeof obj isnt 'object'
        return obj

      if obj instanceof Date
        return new Date(obj.getTime()) 

      if obj instanceof RegExp
        flags = ''
        flags += 'g' if obj.global?
        flags += 'i' if obj.ignoreCase?
        flags += 'm' if obj.multiline?
        flags += 'y' if obj.sticky?
        return new RegExp(obj.source, flags) 

      if obj instanceof Node
        return obj.cloneNode(true)

      newInstance = new obj.constructor()

      for key of obj
        newInstance[key] = pi.utils.clone obj[key]

      return newInstance


    sort: (arr, keys, reverse = false) ->
      arr.sort curry(_keys_compare,[keys,reverse],null,true)

    sort_by: (arr, key, reverse = false) ->
      arr.sort curry(_key_compare,[key,reverse],null,true)
          

    object_matcher: (obj) ->
      for key,val of obj
        if typeof val == "string"
          obj[key] = (value) -> 
            !!value.match new RegExp(val,'i')
        else if val instanceof Object
          obj[key] = object_matcher val
        else
          obj[key] = (value) ->
            val == value

      (item) ->
        for key,matcher of obj
          unless item[key]? and matcher(item[key])
            return false
        return true

    string_matcher: (string) ->
      if string.indexOf(":") > 0
        [path, query] = string.split ":"
        regexp = new RegExp(query,'i')
        (item) ->
          !!item.nod.find(path).text().match(regexp)
      else
        regexp = new RegExp(string,'i')
        (item) ->
          !!item.nod.text().match(regexp)
        

    curry: (fun, args = [], ths = this, last = false) ->
        fun = if ("function" == typeof fun) then fun else ths[fun]
        args = if (args instanceof Array) then args else [args]
        (rest...)->
          fun.apply(ths, if last then rest.concat(args) else args.concat(rest))      

    # return delayed version of function

    delayed: (delay, fun, args = [], ths = this) -> 
        -> 
          setTimeout(pi.utils.curry(fun, args, ths), delay)

    after: (delay, fun, ths) ->
      delayed(delay, fun, [], ths)()
      return

  utils = pi.utils

  # export functions 
  context.curry = utils.curry
  context.delayed = utils.delayed
  context.after = utils.after
  
  # log aliases

  (utils[level] = utils.curry(utils.log,level)) for level,val of _log_levels 

  # Event listener class
  # @private

  class pi.EventListener
    constructor: (@type, @handler, @context = null, @disposable = false, @conditions) ->
      @handler._uuid = "fun"+utils.uuid() if not @handler._uuid?
      @uuid = "#{@type}:#{@handler._uuid}"

      if @context?
        @context._uuid = "obj"+utils.uuid() if not @context._uuid?
        @uuid+=":#{@context._uuid}"
      
    dispatch: (event) ->
      if @disposed
        return
      @handler.call(@context,event)
      @dispose() if @disposable

    dispose: () ->
      @handler = @context = @conditions = null 
      @disposed = true

  # Base Event Dispatcher class for all components
  # Wrapper for underlying native events api (jQuery) and custom events
  # @private

  class pi.EventDispatcher
    constructor: ->
      @listeners = {} # event_type to listener hash
      @listeners_by_key = {} # key is event_type:handler_uuid:context_uuid

    # Attach listener

    on: (event, callback, context, conditions) ->
      @add_listener new pi.EventListener(event, callback, context, false, conditions) 
    
    # Attach disposable (= one-time) listener

    one: (event, callback, context, conditions) ->
      @add_listener new pi.EventListener(event, callback, context, true, conditions) 

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

    off: (event, callback, context, conditions) ->
      @remove_listener event, callback, context, conditions


    # Trigger event
    # @params [String] event
    # @params [Object, Null] data data that will be passed with event as 'event.data'

    trigger: (event, data) ->
      event = $.Event(event) unless event.type?
      event.data = data if data?
      event.target = this
      if @listeners[event.type]?
        utils.debug "Event: #{event.type}"
        for listener in @listeners[event.type]
          listener.dispatch event
          break if event.isPropagationStopped()
        @remove_disposed_listeners()
      return

    ## internal

    add_listener: (listener) ->
      @listeners[listener.type] ||= []
      @listeners[listener.type].push listener
      @listeners_by_key[listener.uuid] = listener

    remove_listener: (type, callback, context = null, conditions = null) ->
      if not type?
        @listeners = {}
        @listeners_by_key = {}
        return

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

  return 