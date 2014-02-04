do (context = this) ->
  "use strict"

  $ = context.$
  pi = context.pi  = context.pi || {}
  
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
        matches = string.match(/([A-Z][^A-Z]*)/g)
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



    curry: (fun, args = [], ths = this) ->
        fun = if ("function" == typeof fun) then fun else ths[fun]
        args = if (args instanceof Array) then args else [args]
        (rest...)->
          fun.apply(ths, args.concat rest)

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

  # event listener & dispatcher todo: add conditions

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



  class pi.EventDispatcher
    constructor: ->
      @listeners = {} # event_type to listener hash
      @listeners_by_key = {} # key is event_type:handler_uuid:context_uuid

    ## API ##

    on: (event, callback, context, conditions) ->
      @add_listener new pi.EventListener(event, callback, context, false, conditions) 
      
    one: (event, callback, context, conditions) ->
      @add_listener new pi.EventListener(event, callback, context, true, conditions) 

    off: (event, callback, context, conditions) ->
      @remove_listener event, callback, context, conditions

    trigger: (event, data) ->
      event = $.Event(event) unless event.type?
      event.data = data unless data?
      event.target = this
      if @listeners[event.type]?
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