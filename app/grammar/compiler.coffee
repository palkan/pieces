'use strict'
parser = require('./pi_grammar').parser
utils = require('../core/utils')

_error = (fun_str) ->
  utils.error "Function [#{fun_str}] was compiled with error"
  false

_operators = 
  # more
  ">": ">"
  #less
  "<": "<"
  #equals (non strict)
  "=": "=="

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
  constructor: (@target={}, fun_str) ->
    if typeof fun_str is 'string'
      @fun_str = fun_str
      try
        @_parsed = @constructor.parse(@fun_str)
      catch e
        @_compiled = utils.curry(_error, [@fun_str])
    else
      @fun_str = 'parsed'
      @_parsed = fun_str

  @parse: (str) ->
    parser.parse(str)

  @compile: (ast) ->
    source = @["_get_#{ast.code}"](ast, '__res = ')

    source = """
    var _ref, __res;
    #{source};
    return __res;
    //# sourceURL=/pi_compiled/source_#{@fun_str}_#{utils.uid()}";\n
    """
    new Function(source)

  call: (ths, args...) ->
    @apply(ths, args)

  apply: (ths, args) ->
    @call_ths = ths || {}
    @compiled().apply(@, args)

  compiled: ->
    @_compiled ||= @constructor.compile(@_parsed)

  @_get_chain: (data, source='') ->
    frst = data.value[0]
    source += 
      switch 
        when frst.name is 'this' then 'this.target' 
        when frst.name is 'app' then 'pi.app'
        when frst.name is 'host' then 'this.target.host' 
        when (frst.code is 'prop' && frst.name is 'view') then 'this.target.view'     
        else
          """
          (function(){
            _ref = (#{@["_get_#{frst.code}"](frst, 'this.call_ths')});
            if(!(_ref == void 0)) return _ref;
            _ref = this.target.scoped && (#{@["_get_#{frst.code}"](frst, 'this.target.scope')});
            if(this.target.scoped && !(_ref == void 0)) return _ref;

            return (#{@["_get_#{frst.code}"](frst,'window')});
          }).call(this)
          """
    i = 1
    while(i<data.value.length)
      step = data.value[i++]
      source = @["_get_#{step.code}"](step, source, data.value[i-1])
    source

  @_get_res: (data, source='', prev_step) ->
    if prev_step?.code is 'res'
      source+".#{data.name}"
    else
      "window.pi.resources.#{data.name}"

  @_get_prop: (data, source='') ->
    source+".#{data.name}"

  @_get_call: (data, source='') ->
    source+".#{data.name}(#{@_get_args(data.args).join(', ')})"

  @_get_args: (args) ->
    @["_get_#{arg.code}"](arg) for arg in args

  @_get_op: (data, source='') ->
    _left = data.left
    _right = data.right

    _type = if data.type is '=' then '==' else data.type

    source+="(#{@["_get_#{_left.code}"](_left)}) #{_type} (#{@["_get_#{_right.code}"](_right)})"

  @_get_if: (data, source='') ->
    source+='(function(){'

    source+="if(#{@["_get_#{data.cond.code}"](data.cond)})"
    
    source+="""
      {
        return (#{@["_get_#{data.left.code}"](data.left)});
      }
      """

    if data.right?
      source+="else{ return (#{@["_get_#{data.right.code}"](data.right)});}"
    
    source+="}).call(this);"

  @_get_simple: (data, source='') ->
    source+@_quote(data.value)

  @_quote: (val) ->
    if typeof val is 'string'
      "'#{val}'"
    else if val && (typeof val is 'object')
      "JSON.parse('#{JSON.stringify(val)}')"
    else
      val

class Compiler
  @modifiers: []

  @parse: (str) ->
    parser.parse(@process_modifiers(str))

  @compile: (ast) ->
    CompiledFun.compile(ast)

  @traverse: (ast, callback, leaves = true) ->
    callback.call(null, ast) unless leaves
    if (ast.code is 'op') || (ast.code is 'if')
      @traverse(ast.left, callback, leaves)
      @traverse(ast.right, callback, leaves)
      @traverse(ast.cond, callback, leaves) if ast.code is 'if'
    else
      callback.call(null, ast)

  @process_modifiers: (str) ->
    for fun in @modifiers
      str = fun.call(null,str)
    str

  @compile_fun: (callstr, target) ->
    callstr = @process_modifiers(callstr) if typeof callstr is 'string'
    new CompiledFun(target, callstr)

  @str_to_fun: @compile_fun

  @str_to_event_handler: (callstr, host) ->
    _f = @compile_fun(callstr, host)
    (e) ->
      _f.call({e: e})

_view_context_mdf = (str) ->
  str.replace(/@(this|app|host|view)(\b)/g, '$1$2').replace(/@@/g,'pi.app.page.context.').replace(/@/g, 'pi.app.view.')

Compiler.modifiers.push _view_context_mdf

module.exports = Compiler
