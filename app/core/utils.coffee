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
        

    debounce: (period, fun, ths = null) ->
      _wait = false
      _buf = null

      (args...) ->
        if _wait
          _buf = args
          return

        pi.utils.after period, ->
          _wait = false
          fun.apply(ths,_buf) if _buf?

        _wait = true
        fun.apply(ths,args) unless _buf?

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

  utils = pi.utils

  # export functions 
  context.curry = utils.curry
  context.delayed = utils.delayed
  context.after = utils.after
  context.debounce = utils.debounce
  
  # log aliases

  (utils[level] = utils.curry(utils.log,level)) for level,val of _log_levels 
  return 