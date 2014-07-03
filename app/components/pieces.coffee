do (context = this) ->
  "use strict"

  # shortcuts
  pi = context.pi  = context.pi || {}
  utils = pi.utils
  pi.config = {}
  Nod = pi.Nod

  pi.API_DATA_KEY = "js_piece"

  pi._storage = {}

  class pi.Base extends pi.Nod

    constructor: (@node, @options = {}) ->
      super
      return unless @node

      @pid = @data('pi')

      @visible = @enabled = true
      @active = false
      @disable() if (@options.disabled || @hasClass('is-disabled'))
      @hide() if (@options.hidden || @hasClass('is-hidden'))
      @activate() if (@options.active || @hasClass('is-active'))

      @initialize()
      @setup_events()
      @init_plugins()

    init_nod: (target) ->
      if typeof target is "string"
        target = Nod.root.find(target) || target
      Nod.create target
    
    init_plugins: ->
      if @options.plugins?
        @attach_plugin name for name in @options.plugins
        
    attach_plugin: (name) ->
      name = utils.camelCase name
      if pi[name]?
        utils.debug "plugin attached #{name}"
        new pi[name] this


    ## internal ##

    initialize: -> 
      pi._storage[@pid] = @ if @pid
      @_initialized = true

    setup_events: ->
      for event, handler of @options.events
        @on event, pi.str_to_fun(handler, this)

    # delegate methods to another object or nested object (then to is string key)

    delegate: (methods, to) ->
      to = if typeof to is 'string' then @[to] else to
      for method in methods
        do (method) => 
          @[method] = (args...) ->
            to[method].apply(to, args)
      return

    ## event dispatcher ##

    trigger: (event, data) ->
      if @enabled or event is 'disabled'
        super event, data

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

  options_re = new RegExp('option(\\w+)', 'i');
  event_re = new RegExp('event(\\w+)', 'i');


  pi.find = (pid) ->
    pi._storage[pid]

  pi.init_component = (nod) ->
    component_name = utils.camelCase(nod.data('component')||'base')
    component = pi[component_name]

    if component? and not nod.data(pi.API_DATA_KEY)
      utils.debug "component created: #{component_name}"
      new pi[component_name](nod.node,pi.gather_options(nod))
    else
      throw new ReferenceError('unknown or initialized component: ' + component_name)
    
  pi.dispose_component = (component) ->
    component = target = if typeof component is 'object' then component else pi.find(component)
    return unless component?
    component.dispose()
    delete pi._storage[component.pid] if component.pid?

  pi.piecify = (context) ->
    context = if context instanceof Nod then context else new Nod(context || document.documentElement)
    context.each(".pi", (nod) ->
      pi.init_component new Nod(nod)
    )
    pi.event.trigger 'piecified', {context: context}
  
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
        opts.events[utils.snake_case(matches[1])] = utils.serialize val

    opts

  pi.call = (component, method_chain, args = []) ->   
    try
      utils.debug "pi call: component - #{component}; method chain - #{method_chain}"
      target = if typeof component is 'object' then component else pi.find(component)

      [method,target] =
        if method_chain.indexOf(".") < 0
          [method_chain, target]
        else
          [_void, target_chain, method_] = method_chain.match(/([\w\d\._]+)\.([\w\d_]+)/)
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


  pi.str_to_fun = (callstr, host = null) ->
    matches = callstr.match(/@([\w\d_]+)(?:\.([\w\d_\.]+)(?:\(([@\w\d\.\(\),'"-_]+)\))?)?/)
    target = if matches[1] == 'this' then host else matches[1]
    if matches[2]
      curry(pi.call,[target, matches[2], (if matches[3] then (pi.prepare_arg(arg,host) for arg in matches[3].split(",")) else [])])
    else
      if typeof target is 'object'       
        -> 
          target
      else
        ->
          pi.find target


  # Global Event Dispatcher

  pi.event = new pi.EventDispatcher()

  utils.extend(
    Nod::, 
    piecify: -> pi.piecify @
    pi_call: (target, action) ->
      if !@_pi_call or @_pi_action != action
        @_pi_action = action
        @_pi_call = pi.str_to_fun action, target
      @_pi_call.call null
    dispose: -> pi.dispose_component @
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

   # export functions 
  context.curry = utils.curry
  context.delayed = utils.delayed
  context.after = utils.after
  context.debounce = utils.debounce

  # find shortcut

  context.$ = (q) ->
    if q[0] is '@'
      pi.find q[1..]
    else if utils.is_html q
      Nod.create q
    else
      Nod.root.find q

  return