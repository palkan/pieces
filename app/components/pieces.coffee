'use strict'
pi = require '../core'
require './compiler'
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
    
    @initialize()
    
    @init_plugins()
    @init_children()
    @setup_events()

    @postinitialize()

  # re-init children (grandchildren and so on)
  # = init_children() + __components__.all -> piecify()

  piecify: ->
    @__components__.length = 0
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

  # setup instance initial state (but not children)
  initialize: ->       
    @disable() if (@options.disabled || @hasClass('is-disabled'))
    @hide() if (@options.hidden || @hasClass('is-hidden'))
    @activate() if (@options.active || @hasClass('is-active'))
    @_initialized = true
    @trigger 'initialized', true, false

  @register_callback 'initialize'

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
        if child?.pid
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
        @on event, pi.Compiler.str_to_event_handler(handler, this)
    delete @options.events
    return

  postinitialize: ->
    @trigger 'creation_complete', true, false

  @register_callback 'postinitialize', as: 'create' 

  dispose: ->
    @trigger 'destroyed', true, false
    super
    if @host?
      @host.remove_component @
    return

  remove_component: (child) ->
    return unless child.pid
    if _array_rxp.test(child.pid)
      delete @["#{child.pid[..-3]}"] if @["#{child.pid[..-3]}"]
    else
      delete @[child.pid]
    @__components__.splice(@__components__.indexOf(child),1)

  remove_children: ->
    list = @__components__.slice()
    for child in list
      @remove_component child
      child.remove()
    super



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


# shortcut
pi.piecify = (nod,host) ->
  pi.init_component nod, host||nod.parent('.pi')

# Global Event Dispatcher

pi.event = new pi.EventDispatcher()

# return component by its path (relative to app.view)
# find('a.b.c') -> app.view.a.b.c

pi.find = (pid_path, from) ->
  utils.get_path pi.app.view, pid_path

utils.extend(
  Nod::, 
  piecify: (host) -> pi.piecify @, host
  pi_call: (target, action) ->
    if !@_pi_call or @_pi_action != action
      @_pi_action = action
      @_pi_call = pi.Compiler.str_to_fun action, target
    @_pi_call.call null
  )

# handle all pi clicks
Nod.root.ready ->
  Nod.root.listen(
    'a', 
    'click', 
    (e) ->
      if e.target.attr("href")[0] == "@"
        e.cancel()
        utils.debug "handle pi click: #{e.target.attr("href")}"
        e.target.pi_call e.target, e.target.attr("href")
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
