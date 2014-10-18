'use strict'
pi = require '../../core'
require './setup'
require './compiler'
require './klass'
require '../events'
utils = pi.utils
Nod = pi.Nod

Init = pi.ComponentInitializer

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
    if @enabled or event is pi.Events.Enabled
      super event, data, bubbles

  bubble_event: (event) ->
    @host.trigger(event) if @host?

  ## public interface ##

  show: -> 
    unless @visible
      @removeClass pi.klass.HIDDEN
      @visible = true
      @trigger pi.Events.Hidden, false
    @

  hide: ->
    if @visible
      @addClass pi.klass.HIDDEN
      @visible = false
      @trigger pi.Events.Hidden, true
    @

  enable: ->
    unless @enabled 
      @removeClass pi.klass.DISABLED
      @enabled = true
      @trigger pi.Events.Enabled, true
    @

  disable: ->
    if @enabled
      @addClass pi.klass.DISABLED
      @enabled = false
      @trigger pi.Events.Enabled, false
    @

  activate: ->
    unless @active 
      @addClass pi.klass.ACTIVE
      @active = true
      @trigger pi.Events.Active, true
    @

  deactivate: ->
    if @active
      @removeClass pi.klass.ACTIVE
      @active = false
      @trigger pi.Events.Active, false
    @

  ## internal ##

  # define instance vars here and other props
  preinitialize: ->
    @node._nod = @
    @__components__ = []
    @__plugins__ = []
    @pid = @data('pid') || @attr('pid') || @node.id
    @visible = @enabled = true
    @active = false

  # setup instance initial state (but not children)
  initialize: ->       
    @disable() if (@options.disabled || @hasClass(pi.klass.DISABLED))
    @hide() if (@options.hidden || @hasClass(pi.klass.HIDDEN))
    @activate() if (@options.active || @hasClass(pi.klass.ACTIVE))
    @_initialized = true
    @trigger pi.Events.Initialized, true, false

  @register_callback 'initialize'

  init_plugins: ->
    if @options.plugins?
      @attach_plugin @find_plugin(name) for name in @options.plugins
      delete @options.plugins
    return
      
  attach_plugin: (plugin) ->
    if plugin?
      utils.debug "plugin attached #{plugin::id}"
      @__plugins__.push plugin.attached(@)

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
    for node in @find_cut(".#{pi.klass.PI}")
      do (node) =>
        child = Init.init node, @
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
    @trigger pi.Events.Created, true, false

  @register_callback 'postinitialize', as: 'create' 

  dispose: ->
    return if @_disposed
    if @host?
      @host.remove_component @
    plugin.dispose() for plugin in @__plugins__
    @__plugins__.length = 0
    super

    @trigger pi.Events.Destroyed, true, false
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