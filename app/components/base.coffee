'use strict'
Klass = require './utils/klass'
Events = require './events'
utils = require '../core/utils'
Nod = require('../core/nod').Nod
Compiler = require '../grammar/compiler'

_array_rxp = /\[\]$/

_proper = (target, name, prop) -> Object.defineProperty(target, name, prop)

_prop_setter =
  'default': (name, val) ->
    if @__properties__[name] != val
      @__properties__[name] = val
      true
    else
      false

  bool: (name, val) ->
    val = !!val
    if @__properties__[name] != val
      @__properties__[name] = val
      true
    else
      false

_toggle_class = (val, class_desc) ->
  return unless class_desc?
  if class_desc.on is val
    @addClass class_desc.name
  else
    @removeClass class_desc.name

_node_attr = (val, node_attr) ->
  return unless node_attr?
  if val is node_attr.on
    @attr(node_attr.name, node_attr.name)
  else
    @attr(node_attr.name, null)

class Base extends Nod
  @include_plugins: (plugins...) ->
    plugin.included(@) for plugin in plugins

  # Add list of required subcomponents
  # If after initialization some required components
  # are missing an error is thrown
  @requires: (components...) ->
    @before_create ->
      while(components.length)
        cmp = components.pop()
        if @[cmp] is undefined
          throw Error("Missing required component #{cmp}") 

  # Generates active property for target
  # - adds __properties__ object to store properties values and description;
  # - generate simple getter (with default values support);
  # - generate setter which can toggle class, trigger events, cast values;
  # - [bool only] generate additional function to set/toggle values.
  #
  # Generated property is not configurable and not enumerable.
  # It's writable unless 'readonly' option is set to true.
  #   
  # @example
  #   @active_property 'enabled', 
  #     type: 'bool', 
  #     event: 'enabled', 
  #     class: 
  #       name: 'is-disabled'
  #       on: false
  #     functions: ['enable', 'disable']
  #     toggle: true
  @active_property = (target, name, options={}) ->
    # ensure that every class has its own props
    target.__prop_desc__ = utils.clone(target.__prop_desc__ || {})

    options.type ||= 'default'

    if options.class? and typeof options['class'] is 'string'
      options.class =
        name: options.class
        on: true

    if options.node_attr? and typeof options.node_attr is 'string'
      options.node_attr =
        name: options.node_attr
        on: true

    target.__prop_desc__[name] = options 

    d = 
      get: ->
        @__properties__[name]

    if !!options.readonly
      d.writable = false
    else
      d.set = (val) ->
        if _prop_setter[options.type].call(@, name, val)
          val = @__properties__[name]
          _toggle_class.call(@, val, options.class)
          _node_attr.call(@, val, options.node_attr)
          @trigger(options.event, val) if options.event?
          @trigger("change:#{name}")
        val

    # generate function aliases for boolean props
    if options.type is 'bool'
      if options.functions?
        # first name is for setting true values
        target[options.functions[0]] = -> 
          @[name] = true
          @
        # second name is for setting false value
        target[options.functions[1]] = -> 
          @[name] = false
          @
      if options.toggle
        toggle_name = if typeof options.toggle is 'string' then options.toggle else "toggle_#{name}"
        target[toggle_name] = (val = null) ->
          if val is null
            @[name] = !@[name]
          else
            @[name] = val
          @

    _proper(target, name, d)

  constructor: (@node, @host, @options = {}) ->
    super

    # 6-step initialization
    @preinitialize()
    @initialize()
    @init_plugins()
    @init_children()
    @setup_events()
    @postinitialize()

  # Define instance vars here and active properties defaults
  preinitialize: ->
    Nod.store(@, true)
    @__properties__ = {}
    @__components__ = []
    @__plugins__ = []
    @pid = @data('pid') || @attr('pid') || @node.id
    
    # Init scope
    @scope = {scope: @} if !!@options.scoped
    @scope ||= @host.scope if @host?.scoped is true
    @scoped = @scope?

    for own name, desc of @__prop_desc__
      do(name, desc) =>
        @__properties__[name] = desc.default

  # Setup instance initial state (but not children)
  initialize: ->       
    @disable() if (@options.disabled || @hasClass(Klass.DISABLED))
    @hide() if (@options.hidden || @hasClass(Klass.HIDDEN))
    @activate() if (@options.active || @hasClass(Klass.ACTIVE))
    @_initialized = true
    @trigger Events.Initialized, true, false

  @register_callback 'initialize'

  # Extend instance functionality with plugins
  # (from options)
  init_plugins: ->
    if @options.plugins?
      @attach_plugin @constructor.lookup_module(name) for name in @options.plugins
      delete @options.plugins
    return

  attach_plugin: (plugin) ->
    if plugin?
      utils.debug_verbose "plugin attached #{plugin::id}"
      @__plugins__.push plugin.attached(@)

  # Find all top-level children components (elements with class Klass.PI)
  # and initialize them
  # 
  # If a child has pid then it would be stored as this[pid]
  # 
  # @example
  #   div.pi id="example"
  #     div.pi data-pid="a"
  #     ul
  #       li.pi data-pid="b"
  #         div.pi data-pid="c"
  #   
  #   # find example as pi.Base
  #   example = pi.find("#example")
  #   example.a # => pi.Base
  #   example.b # => pi.Base
  #   example.b.c #=> pi.Base
  init_children: ->
    for node in @find_cut(".#{Klass.PI}")
      do (node) =>
        child = Nod.create(node).piecify(@)
        @add_component(child)
    return

  # Add event handlers from options
  setup_events: ->
    for event, handlers of @options.events
      for handler in handlers.split(/;\s*/)
        @on event, Compiler.str_to_event_handler(handler, this)
    delete @options.events
    return

  # Finish initialiation and trigger 'created' event.
  postinitialize: ->
    @trigger Events.Created, true, false

  @register_callback 'postinitialize', as: 'create' 

  # re-init children (grandchildren and so on)
  # = init_children() + __components__.all -> piecify()
  piecify: ->
    @__components__.length = 0
    @init_children()
    for c in @__components__
      c.piecify(@)
    @

  ## event dispatcher ##

  trigger: (event, data, bubbles) ->
    if (@_initialized && (@enabled or (event is Events.Enabled)) || event is Events.Destroyed)
      super event, data, bubbles

  bubble_event: (event) ->
    @host.trigger(event) if @host?

  ## public interface ##

  @active_property @::, 'visible', 
    type: 'bool', 
    default: true,
    event: Events.Hidden, 
    class: 
       name: Klass.HIDDEN
       on: false
    functions: ['show', 'hide']

  @active_property @::, 'enabled', 
    type: 'bool',
    default: true
    event: Events.Enabled, 
    class: 
       name: Klass.DISABLED
       on: false
    functions: ['enable', 'disable']

  @active_property @::, 'active', 
    type: 'bool',
    default: true
    event: Events.Active, 
    class: 
       name: Klass.ACTIVE
       on: false
    functions: ['activate', 'deactivate']

  dispose: ->
    return if @_disposed
    @_initialized = false
    if @host?
      @host.remove_component @
    plugin.dispose() for plugin in @__plugins__
    @__plugins__.length = 0
    @__components__.length = 0
    @__properties__ = {}
    @trigger Events.Destroyed, true, false
    super

  add_component: (child) ->
    if child?.pid
      if _array_rxp.test(child.pid)
        arr_name = child.pid[..-3]
        arr = (@[arr_name]||=[])
        @scope[arr_name] = arr if @scoped is true
        arr.push(child) unless arr.indexOf(child)>-1
      else
        @[child.pid] = child
        @scope[child.pid] = child if @scoped is true
    @__components__.push child
    @trigger Events.ChildAdded, child, false

  # Remove all references to child (called when child is disposed)
  remove_component: (child) ->
    return unless child.pid

    name = child.pid
    name = child.pid[..-3] if _array_rxp.test(child.pid)
      
    delete @[name]
    delete @scope[name] if @scoped is true

    @__components__.splice(@__components__.indexOf(child),1)

  # Override Nod#remove_children to handle components first
  remove_children: ->
    list = @__components__.slice()
    for child in list
      @remove_component child
      child.remove()
    super

module.exports = Base
