'use strict'
pi = require '../core'
utils = pi.utils
Nod = pi.Nod

utils.extend pi.Nod::,
  find_cut: (selector) ->
    rest = []
    acc = []

    el = @node.firstChild
      
    while(el)
      if el.nodeType != 1
        el = el.nextSibling || rest.shift()
        continue
      
      if el.matches(selector)
        acc.push el
      else        
        el.firstChild && rest.unshift(el.firstChild)

      el = el.nextSibling || rest.shift()        
  
    acc

_array_rxp = /\[\]$/

class pi.Base extends pi.Nod

  @include_plugins: (plugins...) ->
    plugin.included(@) for plugin in plugins

  @requires: (components...) ->
    @before_create ->
      while(components.length)
        cmp = components.pop()
        if @[cmp] is undefined
          throw Error("Missing required component #{cmp}") 

  constructor: (@node, @host, @options = {}) ->
    super

    @preinitialize()
    
    @__initialize()
    
    @init_plugins()
    @init_children()
    @setup_events()

    @__postinitialize()

  # re-init children (grandchildren and so on)
  # = init_children() + __components__.all -> piecify()

  piecify: ->
    @init_children()
    for c in @__components__
      c.piecify()

  ## event dispatcher ##

  trigger: (event, data, bubbles) ->
    if @enabled or event is 'enabled'
      super event, data, bubbles

  bubble_event: (event) ->
    @host.trigger(event) if @host?

  ## public interface ##

  show: -> 
    unless @visible
      @removeClass 'is-hidden'
      @visible = true
      @trigger 'hidden', false
    @

  hide: ->
    if @visible
      @addClass 'is-hidden'
      @visible = false
      @trigger 'hidden', true
    @

  enable: ->
    unless @enabled 
      @removeClass 'is-disabled'
      @enabled = true
      @trigger 'enabled', true
    @

  disable: ->
    if @enabled
      @addClass 'is-disabled'
      @enabled = false
      @trigger 'enabled', false
    @

  activate: ->
    unless @active 
      @addClass 'is-active'
      @active = true
      @trigger 'active', true
    @

  deactivate: ->
    if @active
      @removeClass 'is-active'
      @active = false
      @trigger 'active', false
    @

  ## internal ##

  # define instance vars here and other props
  preinitialize: ->
    @node._nod = @
    @__components__ = []
    @pid = @data('pid') || @attr('pid') || @node.id
    @visible = @enabled = true
    @active = false

  # [private] Use for callbacks (initialize can be overriden by sub-classs) 
  __initialize: ->
    @initialize()

  # setup instance initial state (but not children)
  initialize: ->       
    @disable() if (@options.disabled || @hasClass('is-disabled'))
    @hide() if (@options.hidden || @hasClass('is-hidden'))
    @activate() if (@options.active || @hasClass('is-active'))
    @_initialized = true
    @trigger 'initialized', true, false

  @register_callback '__initialize', as: 'initialize'

  init_plugins: ->
    if @options.plugins?
      @attach_plugin @find_plugin(name) for name in @options.plugins
      delete @options.plugins
    return
      
  attach_plugin: (plugin) ->
    if plugin?
      utils.debug "plugin attached #{plugin::id}"
      plugin.attached @

  find_plugin: (name) ->
    name = utils.camelCase name
    klass = @constructor
    while(klass?)
      if klass[name]?
        return klass[name]
      klass = klass.__super__?.constructor
    utils.warning "plugin not found: #{name}"
    return null

  init_children: ->
    for node in @find_cut('.pi')
      do (node) =>
        child = pi.init_component node, @
        if child.pid
          if _array_rxp.test(child.pid)
            arr = (@[child.pid[..-3]]||=[])
            arr.push(child) unless arr.indexOf(child)>-1
          else
            @[child.pid] = child
          @__components__.push child
    return

  setup_events: ->
    for event, handlers of @options.events
      for handler in handlers.split(/;\s*/)
        @on event, pi.str_to_event_handler(handler, this)
    delete @options.events
    return

   # [private] Use for callbacks (postinitialize can be overriden by sub-classs) 
  __postinitialize: ->
    @postinitialize()

  postinitialize: ->
    @trigger 'creation_complete', true, false

  @register_callback '__postinitialize', as: 'create' 

  dispose: ->
    super
    if @pid? && @host?
      delete @host[@pid]
    return


event_re = /^on_(.+)/i

pi._guess_component = (nod) ->
  component_name = (nod.data('component') || pi.Guesser.find(nod))
  component = utils.get_class_path pi, component_name
  unless component?
    utils.error "unknown or initialized component #{component_name}"
  else
    utils.debug "component created: #{component_name}"
    component

pi._gather_options = (el) ->
  opts = utils.clone(el.data())

  opts.plugins = if opts.plugins? then opts.plugins.split(/\s+/) else null
  opts.events = {}

  for key,val of opts
    if matches = key.match event_re
      opts.events[matches[1]] = val
  opts


pi.init_component = (nod, host) ->
  nod = if nod instanceof Nod then nod else Nod.create(nod)
  component = pi._guess_component nod
  
  return unless component?

  if nod instanceof component
    return nod 
  else
    new component(nod.node,host,pi._gather_options(nod))

_method_reg = /([\w\.]+)\.(\w+)/

pi.call = (component, method_chain, fixed_args) ->   
  try
    utils.debug "pi call: component - #{component}; method chain - #{method_chain}"
    target = switch 
      when typeof component is 'object' then component 
      when component[0] is '@' then pi.find(component[1..])
      else @[component] 

    return target if !method_chain

    [method,target] =
      if method_chain.indexOf(".") < 0
        [method_chain, target]
      else
        [_, target_chain, method_] = method_chain.match _method_reg
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
    utils.error error

_str_reg = /^['"].+['"]$/

pi.prepare_arg = (arg, host) ->
  if _method_reg.test(arg) or arg[0] is '@' 
    pi.str_to_fun arg, host
  else
    if _str_reg.test(arg) then arg[1...-1] else utils.serialize arg


_condition_regexp = /^([\w\.\(\)@'"-=><]+)\s*\?\s*([\w\.\(\)@'"-]+)\s*(?:\:\s*([\w\.\(\)@'"-]+)\s*)$/
_fun_reg = /^(@?\w+)(?:\.([\w\.]+)(?:\(([@\w\.\(\),'"-]+)\))?)?$/
_op_reg = /(>|<|=)/

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

_conditional = (condition, resolve, reject) ->
  (args...) ->
    if condition.apply(@, args)
      resolve.apply @, args
    else
      reject.apply @, args

_null = -> true

_call_reg = /\(\)/

pi.str_to_fun = (callstr, host) ->
  callstr = callstr.replace _call_reg, ''
  if (matches = callstr.match(_condition_regexp))
    condition = pi.compile_condition matches[1], host
    resolve = pi.compile_fun matches[2], host
    reject = if matches[3] then pi.compile_fun(matches[3],host) else _null
    _conditional condition, resolve, reject
  else
    pi.compile_fun callstr, host

pi.compile_condition = (callstr, host) ->
  if (matches=callstr.match(_op_reg))
    parts = callstr.split _op_reg
    _operators[matches[1]] pi.prepare_arg(parts[0]), pi.prepare_arg(parts[2])
  else
    pi.compile_fun callstr, host

pi.compile_fun = (callstr, host) ->
  matches = callstr.match _fun_reg
  target = switch 
    when matches[1] == '@this' then host 
    when matches[1] == '@app' then pi.app
    when matches[1] == '@host' then host.host # TODO: make more readable
    when matches[1] == '@view' then host.view() # TODO: if we don't use Views?? 
    else matches[1]
  if matches[2]
    utils.curry(pi.call,[target, matches[2], (if matches[3] then (pi.prepare_arg(arg,host) for arg in matches[3].split(",")) else [])])
  else
    utils.curry(pi.call,[target, undefined, undefined])



# the same as pi.str_to_fun, but call with event object

pi.str_to_event_handler = (callstr, host) ->
  callstr = callstr.replace /\be\b/, "e"
  _f = pi.str_to_fun callstr, host
  (e) ->
    _f.call({e: e})

# shortcut for 

pi.piecify = (nod,host) ->
  pi.init_component nod, host||nod.parent('.pi')

# Global Event Dispatcher

pi.event = new pi.EventDispatcher()

# return component by its path (relative to app.view)
# find('a.b.c') -> app.view.a.b.c

pi.find = (pid_path) ->
  utils.get_path pi.app.view, pid_path

utils.extend(
  Nod::, 
  piecify: (host) -> pi.piecify @, host
  pi_call: (target, action) ->
    if !@_pi_call or @_pi_action != action
      @_pi_action = action
      @_pi_call = pi.str_to_fun action, target
    @_pi_call.call null
  )

# handle all pi clicks
Nod.root.ready ->
  Nod.root.listen(
    'a', 
    'click', 
    (e) ->
      if e.target.attr("href")[0] == "@"
        utils.debug "handle pi click: #{e.target.attr("href")}"
        e.target.pi_call e.target, e.target.attr("href")
        e.cancel()
      return
    )

pi.$ = (q) ->
  if q[0] is '@'
    pi.find q[1..]
  else if utils.is_html q
    Nod.create q
  else
    Nod.root.find q


pi.export(pi.$, '$')
return
