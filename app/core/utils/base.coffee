'use strict'
pi = require '../pi'


# export function to global object (window) with ability to rollback (noconflict)
_conflicts = {}

pi.export = (fun, as) ->
  if window[as]?
    _conflicts[as] = window[as] unless _conflicts[as]?
  window[as] = fun

pi.noconflict = () ->
  for own name,fun of _conflicts
    window[name] = fun

class pi.utils

  @uniq_id: 100

  ## regular experssion
  @email_rxp: /\b[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}\b/i
  @digital_rxp: /^[\d\s-\(\)]+$/
  @html_rxp: /^\s*<.+>\s*$/m
  @esc_rxp: /[-[\]{}()*+?.,\\^$|#]/g
  @clickable_rxp: /^(a|button|input|textarea)$/i
  @input_rxp: /^(input|select|textarea)$/i
  @trim_rxp: /^\s*(.*[^\s])\s*$/m
  @notsnake_rxp: /((?:^[^A-Z]|[A-Z])[^A-Z]*)/g
  @str_rxp: /(^'|'$)/


  # Generate uniq string (but int) id
  @uid: ->
    ""+(++@uniq_id)

  ## String functions

  #Escape regular expression characters (to use string in regexp)
  @escapeRegexp: (str) -> 
    str.replace(@esc_rxp, "\\$&")

  @trim: (str) ->
    str.replace(@trim_rxp,"$1")

  @is_digital: (str) ->
    @digital_rxp.test str

  @is_email: (str) ->        
    @email_rxp.test str

  @is_html: (str) ->
    @html_rxp.test str

  @clickable: (node) ->
    @clickable_rxp.test node.nodeName

  @is_input: (node) ->
    @input_rxp.test node.nodeName

  @camelCase: (string) ->
    string = string + ""
    if string.length then (@capitalize(word) for word in string.split('_')).join('') else string

  @snake_case: (string) ->
    string = string + ""
    if string.length 
      matches = string.match @notsnake_rxp
      (word.toLowerCase() for word in matches).join('_') 
    else 
      string
  
  @capitalize: (word) ->
    word[0].toUpperCase()+word[1..] 

  @serialize: (val) ->
    val = switch
      when not val? then null
      when val is 'null' then null
      when val is 'undefined' then undefined
      when val == 'true' then true
      when val == 'false' then false
      when val is '' then ''
      when isNaN(Number(val)) and typeof val is 'string' then (val+"").replace(@str_rxp,'')
      when isNaN(Number(val)) then val
      else Number(val)

  ## Sorting utils

      
  # Compare objects by specific key
  # order is 'asc' or 'desc'
  @key_compare: (a,b,key,order) ->
    reverse = order == 'asc'
    a = @serialize a[key]
    b = @serialize b[key]
    return 0 if a == b
    if !a || a < b
      1+(-2*reverse)
    else 
      -(1+(-2*reverse))

  # Compare objects by several keys
  # params should be of the form: [{key1: 'asc|desc'},{key2:'asc|desc'}]
  @keys_compare: (a,b,params) ->
    r = 0
    for param in params 
      for own key,order of param
        do (key,order) =>
          r_ = @key_compare(a,b,key,order)
          r = r_ if r is 0
    return r

  # sort array by many keys provided as hash: {key: order}
  # order is 'asc' or 'desc'
  @sort: (arr, sort_params) ->
    arr.sort @curry(@keys_compare,[sort_params],@,true)

  # sort array by key
  @sort_by: (arr, key, order = 'asc') ->
    arr.sort @curry(@key_compare,[key,order],@,true)


  ## Object utils

  # return property by path-like name
  # get_path(obj,'a.b.c') = obj.a.b.c
  @get_path: (obj, path) ->
    parts = path.split "."
    res = obj     
    
    while(parts.length)
      key = parts.shift()
      if res[key]?
        res = res[key]
      else
        return null
    res


  # set proprty on path
  @set_path: (obj, path, val) ->
    parts = path.split "."
    res = obj     
    
    while(parts.length>1)
      key = parts.shift()
      unless res[key]?
        res[key] = {}
      res = res[key]
    res[parts[0]] = val

  # convert path parts to camelCase and then get_path
  @get_class_path: (pckg, path) ->
    path = path.split('.').map((p) => @camelCase(p)).join('.')
    @get_path pckg, path

  # generate new object containing as key provided object
  @wrap: (key, obj) ->
    data = {}
    data[key] = obj
    data

  # Clone object (without excepted fields) 
  # @param [Object] obj
  # @param [Array|null] except Array of keys to except (not recursively) 
  @clone: (obj, except=[]) ->
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

    if typeof obj.clone is 'function' 
      return obj.clone()

    newInstance = new obj.constructor()

    for key of obj when (key not in except)
      newInstance[key] = @clone obj[key]

    return newInstance

  # create new object with properties merged (=overwritten)
  @merge: (to, from) ->
    obj = @clone to
    for own key, prop of from
        obj[key]=prop
    obj

  # extend target with data
  # if overwrite set to true - overwrite existing props
  @extend: (target, data, overwrite = false, except=[]) ->
    for own key,prop of data
      if (!target[key]? || overwrite) && !(key in except)
        target[key] = prop
    target

  # fill data with params
  # e.g. 'params' is ['id','name',{tags: ['name','id']}] then 'data' will contain only them from 'source'
  @extract: (data, source, param) ->
    return unless source?
    if Array.isArray(source)
      for el in source
        do(el) =>
          el_data = {}
          @extract(el_data, el, param)
          data.push el_data
      data
    else
      if typeof param is 'string'
        data[param] = source[param] if source[param]?
      else if Array.isArray(param)
        for p in param
          @extract(data,source,p)
      else
        for own key, vals of param
          return unless source[key]?
          if Array.isArray(source[key]) then (data[key]=[]) else (data[key]={})
          @extract(data[key], source[key], vals)
    data


  ## Array utils
  
  @uniq: (arr) ->
    res = []
    for el in arr
      res.push(el) if (el not in res)
    res

  @to_a: (obj) ->
   if Array.isArray(obj) then obj else [obj]

  ## Function utils

  @debounce: (period, fun, ths) ->
    _wait = false
    _buf = null

    (args...) ->
      if _wait
        _buf = args
        return

      (ths||{}).__debounce_id__ = pi.utils.after period, ->
        _wait = false
        if _buf?
          fun.apply(ths,_buf) 
          _buf = null

      _wait = true
      fun.apply(ths,args) unless _buf?

  @curry: (fun, args = [], ths, last = false) ->
      fun = if ("function" == typeof fun) then fun else ths[fun]
      args = pi.utils.to_a args
      (rest...)->
        fun.apply(ths||@, if last then rest.concat(args) else args.concat(rest))      

  # return delayed version of function
  @delayed: (delay, fun, args = [], ths) -> 
      -> 
        setTimeout(pi.utils.curry(fun, args, ths), delay)

  # setTimeout with reverse order of arguments and context
  @after: (delay, fun, ths) ->
    pi.utils.delayed(delay, fun, [], ths)()
  
# export functions 
pi.export pi.utils.curry, 'curry'
pi.export pi.utils.delayed, 'delayed'
pi.export pi.utils.after, 'after'
pi.export pi.utils.debounce, 'debounce'