'use strict'
Guesser = require './guesser'
Nod = require('../../core/nod').Nod
Config = require '../../core/config'
Components = require '../'
utils = require '../../core/utils'

_event_re = /^on_(.+)/i
_bind_re = /^bind_(.+)/i

class Initializer
  # List of builders (ComponentBuilder, ControllerBuilder, etc)
  @builders: []

  @append_builder: (builder) ->
    @builders.push(builder)

  @insert_builder_at: (builder, index) ->
    @builders.splice(index, 0, builder)

  @insert_builder_before: (builder, before_builder) ->
    if (ind = @builders.indexOf(before_builder))>-1
      @insert_builder_at(builder, ind)
    else
      @append_builder(builder)

  @insert_builder_after: (builder, after_builder) ->
    if (ind = @builders.indexOf(before_builder))>-1
      @insert_builder_at(builder, ind+1)
    else
      @append_builder(builder)

  # initialize component or whatever from node (or Nod)
  @init: (nod, host) ->
    nod = if nod instanceof Nod then nod else Nod.create(nod)
    
    for builder in @builders when builder.match(nod)
      return builder.build(nod, host)

  # parse DOM options for component and merge with config options
  @gather_options: (el, config_name = "base") ->
    opts = utils.clone(el.data())

    opts.plugins = if opts.plugins? then opts.plugins.split(/\s+/) else null
    opts.events = {}
    opts.bindings = {}

    for key,val of opts
      if matches = key.match _event_re
        opts.events[matches[1]] = val
      if matches = key.match _bind_re
        opts.bindings[matches[1]] = val

    # merge options with defaults
    utils.merge((utils.obj.get_path(Config, config_name)||{}), opts)

# Creates component from node
class ComponentBuilder
  # Component builder match any nod
  @match: utils.truthy

  @build: (nod, host) ->
    component = @guess_component(nod)   
    return unless component?

    return nod if nod instanceof component
    
    new component(nod.node, host, Initializer.gather_options(nod, "components.#{component.class_name}"))

  # return component class for nod
  @guess_component: (nod) ->
    component_name = nod.data('component') || Guesser.find(nod)
    component = utils.obj.get_class_path(Components, component_name)
    unless component?
      utils.error "Unknown component #{component_name}", nod.data()
    else
      # here we store component class name (snake_case) in Component class itself
      component.class_name = component_name
      utils.debug_verbose "Component created: #{component_name}"
      component

Initializer.append_builder ComponentBuilder

module.exports = Initializer
