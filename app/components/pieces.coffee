do (context = this) ->
  "use strict"

  # shortcuts
  pi = context.pi  = context.pi || {}
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
          nod = el.querySelector selector
          if nod?
            rest.push nod
        else        
          if (nod = el.querySelector(selector))
            el.nextSibling && rest.unshift(el.nextSibling)
            el = nod
            continue
        el = el.nextSibling || rest.shift()        
    
      acc


  class pi.Base extends pi.Nod

    constructor: (@node, @host, @options = {}) ->
      return unless @node

      @node._nod.dispose() if @node._nod?
      super

      @pid = @data('pid')

      @preinitialize()
      
      @initialize()
      
      @init_plugins()
      @init_children()
      @setup_events()

      @postinitialize()

    ## event dispatcher ##

    trigger: (event, data, bubbles) ->
      if @enabled or event is 'disabled'
        super event, data, bubbles

    ## public interface ##

    show: -> 
      unless @visible
        @removeClass 'is-hidden'
        @visible = true
        @trigger 'shown'
      @

    hide: ->
      if @visible
        @addClass 'is-hidden'
        @visible = false
        @trigger 'hidden'
      @

    enable: ->
      unless @enabled 
        @removeClass 'is-disabled'
        @attr 'disabled',null
        @enabled = true
        @trigger 'enabled'
      @

    disable: ->
      if @enabled
        @addClass 'is-disabled'
        @attr 'disabled', 'disabled'
        @enabled = false
        @trigger 'disabled'
      @

    activate: ->
      unless @active 
        @addClass 'is-active'
        @active = true
        @trigger 'active'
      @

    deactivate: ->
      if @active
        @removeClass 'is-active'
        @active = false
        @trigger 'inactive'
      @

    ## internal ##

    # define instance vars here
    preinitialize: ->
      @visible = @enabled = true
      @active = false

    # setup instance initial state (but not children)
    initialize: ->       
      @disable() if (@options.disabled || @hasClass('is-disabled'))
      @hide() if (@options.hidden || @hasClass('is-hidden'))
      @activate() if (@options.active || @hasClass('is-active'))
      @_initialized = true
      @trigger 'initialized', true, false

    init_plugins: ->
      if @options.plugins?
        @attach_plugin @find_plugin(name) for name in @options.plugins
        
    attach_plugin: (plugin) ->
      if plugin?
        utils.debug "plugin attached #{plugin.class_name()}"
        @include plugin

    find_plugin: (name) ->
      name = utils.camelCase name
      klass = @constructor
      while(klass?)
        if klass[name]?
          return klass[name]
        klass = klass.__super__
      return null

    init_children: ->
      for node in @find_cut('.pi')
        child = pi.init_component node, @
        if child.pid?
          @[child.pid] = child

    setup_events: ->
      for event, handlers of @options.events
        for handler in handlers.split(/;\s*/)
          @on event, pi.str_to_event_handler(handler, this)

    postinitialize: ->
      @trigger 'creation_complete', true, false

    dispose: ->
      super
      if @pid? && @host?
        delete @host[@pid]
      return


  options_re = /option(\\w+)/i
  event_re = /event(\\w+)/i


  pi.find = (pid_path) ->
    null

  pi.init_component = (nod, host) ->
    component_name = utils.camelCase(nod.data('component')||'base')
    component = pi[component_name]

    unless component?
      throw new ReferenceError('unknown or initialized component: ' + component_name)
    else if nod instanceof component
      return nod 
    else
      utils.debug "component created: #{component_name}"
      new pi[component_name](nod.node,host,pi.gather_options(nod))

  pi.gather_options = (el) ->
    el = if el instanceof Nod then el else new Nod(el)

    opts =
      component: el.data('component') || 'base'               
      plugins: if el.data('plugins') then el.data('plugins').split(/\s+/) else null
      events: {}

    for key,val of el.data()
      if matches = key.match options_re
        opts[utils.snake_case(matches[1])] = utils.serialize val
        continue
      if matches = key.match event_re
        opts.events[utils.snake_case(matches[1])] = val

    opts

  _method_reg = /([\w\._]+)\.([\w_]+)/

  pi.call = (component, method_chain, args...) ->   
    try
      utils.debug "pi call: component - #{component}; method chain - #{method_chain}"
      target = if typeof component is 'object' then component else pi.find(component)

      [method,target] =
        if method_chain.indexOf(".") < 0
          [method_chain, target]
        else
          [_void, target_chain, method_] = method_chain.match _method_reg
          target_ = target
          for key_ in target_chain.split('.') 
            do (key_) ->
              target_ = target_[key_]
          [method_, target_]
      if target[method]?.call?
        target[method].apply(target, ((if typeof arg is 'function' then arg.call(null) else arg) for arg in args))
      else
        target[method]
    catch error
      utils.error error

  _str_reg = /^['"].+['"]$/

  pi.prepare_arg = (arg, host) ->
    if arg[0] is "@"
      pi.str_to_fun arg, host
    else
      if _str_reg.test(arg) then arg[1...-1] else utils.serialize arg


  _fun_reg = /@([\w]+)(?:\.([\w\.]+)(?:\(([@\w\.\(\),'"-_]+)\))?)?/

  pi.str_to_fun = (callstr, host) ->
    matches = callstr.match _fun_reg
    target = if matches[1] == 'this' then host else matches[1]
    if matches[2]
      curry(pi.call,[target, matches[2]].concat(if matches[3] then (pi.prepare_arg(arg,host) for arg in matches[3].split(",")) else []))
    else
      if typeof target is 'object'       
        -> 
          target
      else
        ->
          pi.find target


  # the same as pi.str_to_fun, but accept only one argument and extract 'data' from it

  pi.str_to_event_handler = (callstr, host) ->
    _f = pi.str_to_fun callstr, host
    (e) ->
      _f e.data

  # Global Event Dispatcher

  pi.event = new pi.EventDispatcher()

  utils.extend(
    Nod::, 
    piecify: -> pi.init_component @, @parent('.pi')
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

  # magic function
  context.$ = (q) ->
    if q[0] is '@'
      pi.find q[1..]
    else if utils.is_html q
      Nod.create q
    else
      Nod.root.find q

  return