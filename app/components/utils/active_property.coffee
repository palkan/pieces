'use strict'
utils = require '../../core/utils'

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

class ActiveProperty
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
  #   ActiveProperty.create Base, 'enabled', 
  #     type: 'bool', 
  #     event: 'enabled', 
  #     class: 
  #       name: 'is-disabled'
  #       on: false
  #     functions: ['enable', 'disable']
  #     toggle: true
  @create = (target, name, options={}) ->
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

  @initialize: (target) ->
    target.__properties__ = {}
    for own name, desc of (target.__prop_desc__ || {})
      do(name, desc) ->
        target.__properties__[name] = desc.default

  @dispose: (target) ->
    target.__properties__ = {}

module.exports = ActiveProperty
