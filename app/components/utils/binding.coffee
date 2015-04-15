'use strict'
utils = require '../../core/utils'
Compiler = require '../../grammar/compiler'
Events = require '../events'
EventDispatcher = require('../../core/events').EventDispatcher

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

    @bindables = []

    @initialize()
    @invalidate()

  initialize: ->
    chains = []

    Compiler.traverse(@ast, (node) ->
      chains.push(node) if (node.code is 'chain') 
    )

    for chain in chains
      @_init_chain(chain.value)

    @initialized = true

  _init_chain: (steps) ->
    @bindables.push(new ChainBindable(@, @target, steps))

  invalidate: ->
    return unless @initialized
    flag = true
    for bindable in @bindables
      flag = flag && bindable.enabled
    @update(!flag) if flag != @enabled
    @enabled = flag

  update: (nullify = false) ->
    val = if nullify then '' else @compiled.call()
    @callback.call(null, val)

class ChainBindable
  constructor: (@binding, @target, steps) ->
    @steps = @_build_list(steps)
    @enabled = false

    @listeners = 
      destroy: []
      bindable: []
      create: []
    
    @init_bound = @initialize.bind(@)
    @disable_bound = @disable.bind(@)
    @update_bound = @update.bind(@)
    
    @initialize() if @steps.length > 0

  initialize: ->
    @remove_listeners()
    if @target._disposed
      @enabled = false
      return @binding.invalidate()

    i = 0
    target = @target
    while(i < @steps.length)
      @steps[i].fun.target = target
      target = @steps[i].fun.apply(target)
      break unless @_check_target(target, @steps[i+1]?.name, i is 0)
      i++

    @enabled = i is @steps.length - 1
    @binding.invalidate()

  remove_listeners: ->
    for own type,list of @listeners
      for l in list
        @["_unregister_#{type}"](l)

    @listeners.destroy.length = 0
    @listeners.bindable.length = 0
    @listeners.create.length = 0

  update: ->
    return unless @enabled
    utils.debug 'update'
    @binding.update()

  disable: ->
    return unless @enabled
    # async call, because we have to white untill target is completely destroyed
    utils.after 0, =>
      @initialize()

  _check_target: (target, name, root) ->
    return unless name?

    @_register_destroy(target, root)

    if target.__prop_desc__?[name]
      @_register_bindable(target, name)
    else if !target[name]?
      @_register_create(target, name)
      return
    true

  _register_destroy: (target, root = false) ->
    utils.debug 'destroy', target, root
    @listeners.destroy.push target
    target.on Events.Destroyed, @disable_bound

  _unregister_destroy: (target) ->
    utils.debug 'unregister destroy', target
    target.off(Events.Destroyed, @disable_bound) unless target._disposed

  _register_bindable: (target, name) ->
    utils.debug 'bindable', target, name
    @listeners.bindable.push {target: target, name: name}
    target.on "change:#{name}", @update_bound

  _unregister_bindable: (data) ->
    {target: target, name: name} = data
    utils.debug 'unregister bindable', target, name
    target.off("change:#{name}", @update_bound) unless target._disposed

  _register_create: (target, name) ->
    utils.debug 'create', target, name
    @listeners.create.push {target: target, name: name}
    target.on(Events.ChildAdded, @init_bound, target, (e) -> e.data.pid is name) 

  _unregister_create: (data) ->
    {target: target, name: name} = data
    utils.debug 'unregister create', target, name
    target.off(Events.ChildAdded, @init_bound) unless target._disposed

  _build_list: (steps) ->
    for step in steps
      suffix = if step.code is 'call' then '()' else ''
      step.fun = Compiler.compile_fun(step.name + suffix)
    steps


module.exports = Binding
