'use strict'
pi = require '../../core'
parser = require('../../grammar/pi_grammar').parser
utils = pi.utils

_true = -> true
_null = ->
_error = (fun_str) ->
  utils.error "Function [#{fun_str}] was compiled with error"
  false

_operators = 
  # more
  ">": (a, b) ->
        a > b
  #less
  "<": (a, b) ->
        a < b
  #equals (non strict)
  "=": (a, b) ->
        a == b
  "bool": (a) -> !!a

# parse function string and convert fun tree to callable
# possible node codes:
#   chain - get method chain res ('app.view.hide(true)')
#   prop - get object property ('app')
#   call - call object fun ('hide(true)')
#   if - get conditinal call res ('e.data ? show() : hide()')
#   res - get resource ('User')
#   simple - constant value
#
#  _parse_[...] methods return functions 
#  _get_[...] methods return result

class CompiledFun
  constructor: (@target={}, @fun_str) ->
    try
      @_parsed = parser.parse(fun_str)
    catch e
      @_compiled = utils.curry(_error, [fun_str])

  call: (ths, args...) ->
    @apply(ths, args)

  apply: (ths, args) ->
    @call_ths = ths || {}
    @compiled().apply(@, args)

  compiled: ->
    @_compiled ||= @_compile_fun() 

  _compile_fun: ->
    =>
      @["_get_#{@_parsed.code}"](@_parsed)

  _get_chain: (data) ->
    frst = data.value[0]
    _target = 
      switch frst.name 
        when 'this' then @target 
        when 'app' then pi.app
        when 'host' then @target.host 
        when 'view' then @target.view?()     
        else (@["_get_#{frst.code}"](frst, @call_ths) || @["_get_#{frst.code}"](frst,window))
    i = 1
    while(i<data.value.length)
      step = data.value[i++]
      _target = @["_get_#{step.code}"](step,_target)
    _target

  _get_res: (data, from = {}) ->
    from[data.name] || pi.resources[data.name]

  _get_prop: (data, from) ->
    from[data.name]

  _get_call: (data, from) ->
    from[data.name].apply(from, @_get_args(data.args))

  _get_args: (args) ->
    @["_get_#{arg.code}"](arg) for arg in args

  _get_if: (data) ->
    _left = data.cond.left
    _right = data.cond.right
    
    _left = @["_get_#{_left.code}"](_left)
    _right = @["_get_#{_right.code}"](_right) if _right?

    if _operators[data.cond.type](_left,_right)
      @["_get_#{data.left.code}"](data.left)
    else if data.right?
      @["_get_#{data.right.code}"](data.right)
    else
      false  

  _get_simple: (data) ->
    data.value

class pi.Compiler
  @modifiers: []

  @process_modifiers: (str) ->
    for fun in @modifiers
      str = fun.call(null,str)
    str

  @compile_fun: (callstr, target) ->
    callstr = @process_modifiers(callstr)
    new CompiledFun(target, callstr)

  @str_to_fun: @compile_fun

  @str_to_event_handler: (callstr, host) ->
    _f = @compile_fun(callstr, host)
    (e) ->
      _f.call({e: e})

_view_context_mdf = (str) ->
  str.replace(/@(this|app|host|view)(\b)/g, '$1$2').replace(/@@/g,'pi.app.page.context.').replace(/@/g, 'pi.app.view.')

pi.Compiler.modifiers.push _view_context_mdf
pi.call = pi.Compiler.call

module.exports = pi.Compiler
