do (context = this) ->
  "use strict"

  pi = context.pi  = context.pi || {}
  
  _email_regexp = /\b[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}\b/i
  _html_regexp = /^<.+>$/m

  _uniq_id = 100

  _key_compare = (a,b,key,reverse) ->
    return 0 if a[key] == b[key]
    if !a[key] || a[key] < b[key]
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


  pi.utils =

    uuid: ->
      ""+(++_uniq_id)

    #Escape regular expression characters (to use string in regexp)
    escapeRegexp: (str) -> 
        str.replace(/[-[\]{}()*+?.,\\^$|#]/g, "\\$&")

    
    is_email:(str) ->        
      _email_regexp.test str

    is_html: (str) ->
      _html_regexp.test str


    camelCase: (string) ->
      string = string + ""
      if string.length then (pi.utils.capitalize(word) for word in string.split('_')).join('') else string

    snake_case: (string) ->
      string = string + ""
      if string.length 
        matches = string.match(/((?:^[^A-Z]|[A-Z])[^A-Z]*)/g)
        (word.toLowerCase() for word in matches).join('_') 
      else 
        string
    
    capitalize: (word) ->
      word[0].toUpperCase()+word[1..] 

    serialize: (val) ->
      val = switch
        when not val? then null
        when val == 'true' then true
        when val == 'false' then false
        when isNaN(Number(val)) then val 
        else Number(val)

    # Clone object (without excepted fields) 
    # @param [Object] obj
    # @param [Array|null] except Array of keys to except (not recursively) 

    clone: (obj, except=[]) ->
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

      if obj instanceof Element
        return obj.cloneNode(true)

      newInstance = new obj.constructor()

      for key of obj when (key not in except)
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

    # create new object with properties merged

    merge: (to, from) ->
      obj = pi.utils.clone to
      for own key, prop of from
          obj[key]=prop
      obj

    # extend target with data (skip existing props)

    extend: (target, data) ->
      for own key,prop of data
        unless target[key]?
          target[key] = prop
      target
  return 