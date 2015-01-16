'use strict'
pi = require '../../core'
utils = pi.utils

event_re = /^on_(.+)/i

class pi.ComponentInitializer
  @guess_component: (nod) ->
    component_name = nod.data('component') || pi.Guesser.find(nod)
    component = utils.obj.get_class_path(pi, component_name)
    unless component?
      utils.error "Unknown component #{component_name}", nod.data()
    else
      # here we store component class name (snake_case) in Component class itself
      component.class_name = component_name
      utils.debug "Component created: #{component_name}"
      component

  @gather_options: (el, component_name = "base") ->
    opts = utils.clone(el.data())

    opts.plugins = if opts.plugins? then opts.plugins.split(/\s+/) else null
    opts.events = {}

    for key,val of opts
      if matches = key.match event_re
        opts.events[matches[1]] = val
    # merge options with defaults
    utils.merge((pi.config[component_name]||{}), opts)


  @init: (nod, host) ->
    nod = if nod instanceof pi.Nod then nod else pi.Nod.create(nod)
    component = @guess_component nod
    
    return unless component?

    if nod instanceof component
      return nod 
    else
      new component(nod.node,host,@gather_options(nod, component.class_name))