'use strict'
utils = require './utils'
Core = require './core'
Compiler = require '../grammar/compiler'
EventDispatcher = require('./events').EventDispatcher

exports = {}

# Create one-way binding beetween component's method/property
# and provided expression.
# 
# Example:
#   # enable component when 'input' value length is greater that 0
#   new Binding(component, 'enabled', "input.val.length > 0")
#   # render User with id 1 on every update
#   new Binding(component, 'render', "User(1)")
class Binding
  constructor: (@target, method, @expression) ->
    if typeof @target[method] is 'function'
      @callback = @target[method].bind(@target)
    else
      # setter
      @callback = (val) => @target[method] = val

    @compiled = Compiler.compile_fun(@expression, @target)
    @ast = @compiled._parsed

    @initialized = false
    @_disposed = false

    @listeners = []

    @initialize()
    @invalidate()

  initialize: ->
    return if @_disposed
    chains = []

    Compiler.traverse(@ast, (node) ->
      chains.push(node) if (node.code is 'chain') 
    )

    @process_chain(chain.value) for chain in chains

    @initialized = true

  process_chain: (parts) ->
    @listeners.push(new BindListener(@, @target, parts))

  invalidate: ->
    return unless @initialized
    flag = true
    for bindable in @listeners
      return @dispose() if bindable._disposed
      flag = flag && bindable.enabled
    @update(!flag) if flag || (flag != @enabled)
    @enabled = flag

  update: (nullify = false) ->
    return unless @initialized
    val = if nullify then '' else @compiled.call(@target)
    @callback.call(null, val)

  dispose: ->
    return if @_disposed
    @_disposed = true
    for bindable in @listeners
      bindable.dispose()
    @listeners.length = 0
    @update(true)
    @initialized = false
    @target = null
    @callback = null


exports.Binding = Binding

# Extract bindables from chain and monitor them 
class BindListener extends Core
  @types: [
    {name: 'object', fun: (val) -> (typeof val is 'object') || (typeof val is 'function') },
    {name: 'simple', fun: (val) -> !(typeof val is 'object')}
  ]

  @prepend_type: (type, fun) ->
    @types.splice(0, 0, {name: type, fun: fun})

  @append_type: (type, fun) ->
    @types.push({name: type, fun: fun})

  constructor: (@binding, @target, steps) ->
    @steps = @_build_list(steps)
    @enabled = @_disposed = false
    @listeners = []

    @_init = @initialize.bind(@)
    @_disable = @disable.bind(@)
    @_update = @update.bind(@)
    
    @initialize()

  initialize: ->
    return if @_disposed
    @remove_listeners()

    return @dispose() if @target._disposed

    i = 0
    target = @target
    @failed = 0
    size = @steps.length
    while(i < @steps.length)
      @steps[i].fun.target = target
      target = @steps[i].fun.apply(target)
      break unless @_check_target(target, @steps[i+1]?.name, i is 0, i is (size - 1))
      i++

    @enabled = @failed is 0
    @binding.invalidate()

  dispose: ->
    return if @_disposed
    @remove_listeners()
    @_disposed = true
    @enabled = false
    @binding.invalidate()
    @binding = null
    @target = null

  disable: ->
    return unless @enabled
    # async call, because we have to wait until target is completely destroyed
    utils.after 0, =>
      @initialize()

  update: ->
    return unless @enabled
    utils.debug 'update'
    @binding.invalidate()

  remove_listeners: ->
    listener.dispose() for listener in @listeners
    @listeners.length = 0

  _build_list: (steps) ->
    for step in steps
      step.fun = Compiler.compile_fun(@_to_chain(step))
    steps

  _to_chain: (data) ->
    {code: 'chain', value: [data]}

  _check_target: (target, name, root, last) ->
    # it's only happens when root target is undefined (which means that we cannot bind anything)
    return @dispose() unless last || target?

    type = @_detect_type(target)

    @["handle_#{type}"]?(target, name, root, last)

  _detect_type: (target) ->
    for probe in @constructor.types when probe.fun.call(null, target)
      return probe.name
    return ''

  # handle simple objects (only checks that field `name` exists)
  handle_object: (target, name, _root, last) ->
    unless last || target[name]?
      @failed++
      return
    true

  # simple targets (int, string etc)
  handle_simple: ->
    true

exports.BindListener = BindListener

# Bindable module.
# Provides 'bind' and 'unbind' methods.
class Bindable extends Core
  @included: (base) ->
    base.extend @

  bind: (to, expression) ->
    (@__bindings__||={})["#{to}::#{expression}"] ||= new Binding(@, to, expression)

  unbind: (to='', expression='') ->
    return unless @__bindings__?
    match = "#{to}"
    match += "::#{expression}" if expression
    for k in Object.keys(@__bindings__) when k.indexOf(match) is 0
      @__bindings__[k].dispose()
      delete @__bindings__[k]

exports.Bindable = Bindable

module.exports = exports
