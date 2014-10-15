'use strict'
pi = require '../core'
utils = pi.utils


_method_rxp = /([\w\.]+)\.(\w+)/
_str_rxp = /^['"].+['"]$/
_condition_rxp = /^(.*\S)\s*\?\s*(@?[\w\.]+(?:\(.*\S\))?)\s*(?:\:\s*(@?[\w\.]+(?:\(.*\S\))?)\s*)$/

_fun_rxp = /^(@?\w+)(?:\.([\w\.]+)(?:\((.+)\))?)?$/
_op_rxp = /(>|<|=)/

_true = -> true
_null = ->

_operators = 
  # more
  ">": (left, right) ->
        (args...) ->
          a = left.apply?(@,args) || left
          b = right.apply?(@,args) || right
          a > b
  #less
  "<": (left, right) ->
        (args...) ->
          a = left.apply?(@,args) || left
          b = right.apply?(@,args) || right
          a < b
  #equals (non strict)
  "=": (left, right) ->
        (args...) ->
          a = left.apply?(@,args) || left
          b = right.apply?(@,args) || right
          a == b

_call_rxp = /\(\)/

class pi.Compiler
  @modifiers: []

  @process_modifiers: (str) ->
    for fun in @modifiers
      str = fun.call(null,str)
    str

  @call: (owner, target, method_chain, fixed_args) ->   
    try
      utils.debug "pi call: target - #{target}; method chain - #{method_chain}"
      target = switch 
        when typeof target is 'object' then target 
        when target[0] is '@' then pi.find(target[1..],owner)
        else @[target] # when call with context (str_to_event_listener)

      return target if !method_chain

      [method,target] =
        if method_chain.indexOf(".") < 0
          [method_chain, target]
        else
          [_, target_chain, method_] = method_chain.match _method_rxp
          target_ = target
          for key_ in target_chain.split('.') 
            do (key_) ->
              target_ = if typeof target_[key_] is 'function' then target_[key_].call(target_) else target_[key_]
          [method_, target_]
      if target[method]?.call?
        target[method].apply(target, ((if typeof arg is 'function' then arg.apply(@) else arg) for arg in fixed_args))
      else
        target[method]
    catch error
      utils.error error, {backtrace: error.stack, target: target, method: method_chain, args: fixed_args} 

  @is_simple_arg: (arg) ->
    not (_method_rxp.test(arg) or arg[0] is '@')


  @prepare_arg: (arg, host) ->
    if @is_simple_arg(arg)
      if _str_rxp.test(arg) then arg[1...-1] else utils.serialize arg
    else
      @str_to_fun arg, host

  @_conditional: (condition, resolve, reject) ->
    (args...) ->
      if condition.apply(@, args)
        resolve.apply @, args
      else
        reject.apply @, args

  @str_to_fun: (callstr, host) ->
    callstr = @process_modifiers(callstr)
    if (matches = callstr.match(_condition_rxp))
      condition = @compile_condition matches[1], host
      resolve = @compile_fun matches[2], host
      reject = if matches[3] then @compile_fun(matches[3],host) else _true
      @_conditional condition, resolve, reject
    else
      @compile_fun callstr, host

  @compile_condition: (callstr, host) ->
    if (matches=callstr.match(_op_rxp))
      parts = callstr.split _op_rxp
      _operators[matches[1]] @prepare_arg(parts[0]), @prepare_arg(parts[2])
    else
      @compile_fun callstr, host

  @parse_str: (callstr) ->
    if(matches = callstr.match _fun_rxp)
      res = target: matches[1], method_chain: matches[2], args: if matches[3] then matches[3].split(",") else []
    else
      false

  @compile_fun: (callstr, target) ->
    if(data = @parse_str(callstr))
      data.target = switch 
        when data.target == '@this' then target 
        when data.target == '@app' then pi.app
        when data.target == '@host' then target.host 
        when data.target == '@view' then target.view?() 
        else data.target
      if data.method_chain
        utils.curry(pi.call,[target, data.target, data.method_chain, (if data.args then (@prepare_arg(arg,target) for arg in data.args) else [])])
      else
        utils.curry(pi.call,[target, data.target, undefined, undefined])
    else
      utils.error "cannot compile function: #{callstr}"
      _null

  @str_to_event_handler: (callstr, host) ->
    callstr = callstr.replace /\be\b/, "e"
    _f = @str_to_fun callstr, host
    (e) ->
      _f.call({e: e})

pi.call = pi.Compiler.call
pi.Compiler.modifiers.push (str) -> str.replace(_call_rxp, '')