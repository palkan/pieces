do (context = this) ->
  "use strict"

  # shortcuts
  pi = context.pi  = context.pi || {}
  utils = pi.utils
  pi.config = {}
  Nod = pi.Nod

  pi.API_DATA_KEY = "js_piece"

  pi._storage = {}

  class pi.Base extends pi.NodEventDispatcher

    constructor: (target, @options = {}) ->
      super
      @visible = @enabled = true
      @active = false
      @init_nod target
      return unless @nod

      @node = @nod.node

      @disable() if (@options.disabled || @nod.hasClass('is-disabled'))
      @hide() if (@options.hidden || @nod.hasClass('is-hidden'))
      @activate() if (@options.active || @nod.hasClass('is-active'))
      @_value = @nod.data('value')
      @nod.data(pi.API_DATA_KEY, this)
      @initialize()
      @setup_events()
      @init_plugins()

    init_nod: (target) ->
      if typeof target is "string"
        @nod = new Nod(Nod.root.find(target))
      else
        @nod = Nod.create target
    
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
      pi._storage[@nod.data('pi')] = @ if @nod.data('pi')
      @_initialized = true

    

    setup_events: ->
      for event, handler of @options.events
        @on event, pi.str_to_fun(handler, this)

    changed: (property) ->
      @trigger property, this[property]
      @trigger "#{property}_#{this[property]}"
      return

    delegate: (methods, to) ->
      for method in methods
        do (method) =>
          @[method] = (args...) =>
            @[to][method].apply(this, args)
          return
      return

    ## event dispatcher ##

    trigger: (event, data) ->
      if @enabled or event is 'enabled'
        super event, data

    ## public interface ##

    show: -> 
      if not @visible
        @nod.removeClass 'is-hidden'
        @visible = true
        @changed 'visible'

    hide: ->
      if @visible
        @nod.addClass 'is-hidden'
        @visible = false
        @changed 'visible'

    enable: ->
      if not @enabled 
        @nod.removeClass 'is-disabled'
        @nod.get(0).removeAttribute('disabled')
        @enabled = true
        @changed 'enabled'

    disable: ->
      if @enabled
        @nod.addClass 'is-disabled'
        @nod.get(0).setAttribute('disabled', 'disabled')
        @enabled = false
        @changed 'enabled'

    activate: ->
      if not @active 
        @nod.addClass 'is-active'
        @active = true
        @changed 'active'

    deactivate: ->
      if @active
        @nod.removeClass 'is-active'
        @active = false
        @changed 'active'

    value: (val = null) ->
      if val?
        @_value = val
      @_value

    move: (x,y) ->
      @nod.css left: x, top: y

    position: () ->
      {left: x, top: y} = @nod.position()
      x: x, y: y 

    offset: () ->
      {left: x, top: y} = @nod.offset()
      x: x, y: y 

    size: (width = null, height = null) ->
      unless width? and height?
        return width: @nod.width(), height: @nod.height()
      
      if width? and height?
        @nod.width width
        @nod.height height
      else
        old_h = @nod.height()
        old_w = @nod.width()
        if width?
          @nod.width width
          @nod.height (old_h * width/old_w)
        else
          @nod.height height
          @nod.width (old_w * height/old_h)
      @trigger 'resize'
      return

    width: (width = null) ->
      unless width?
        return @nod.width()

      @nod.width width 
      @trigger 'resize'
      return

    height: (height = null) ->
      unless height?
        return @nod.height()

      @nod.height height 
      @trigger 'resize'
      return



  options_re = new RegExp('option(\\w+)', 'i');
  event_re = new RegExp('event(\\w+)', 'i');

  pi.init_component = (nod) ->
    component_name = utils.camelCase(nod.data('component')||'base')
    component = pi[component_name]

    if component? and not nod.data(pi.API_DATA_KEY)
      utils.debug "component created: #{component_name}"
      new pi[component_name](nod,pi.gather_options(nod))
    else
      throw new ReferenceError('unknown or initialized component: ' + component_name)
    

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
        opts[utils.snakeCase(matches[1])] = utils.serialize val
        continue
      if matches = key.match event_re
        opts.events[utils.snakeCase(matches[1])] = utils.serialize val

    opts

  pi.call = (component, method_chain, args = []) ->   
    try
      utils.debug "pi call: component - #{component}; method chain - #{method_chain}"
      target = if typeof component is 'object' then component else pi._storage[component]

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

  pi.prepare_arg = (arg, host) ->
    if arg[0] is "@"
      pi.str_to_fun arg, host
    else
      utils.serialize arg


  pi.str_to_fun = (callstr, host = null) ->
    matches = callstr.match(/@([\w\d_]+)(?:\.([\w\d_\.]+)(?:\(([@\w\d\.\(\),]+)\))?)?/)
    target = if matches[1] == 'this' then host else matches[1]
    if matches[2]
      curry(pi.call,[target, matches[2], (if matches[3] then (pi.prepare_arg(arg,host) for arg in matches[3].split(",")) else [])])
    else
      if typeof target is 'object'       
        -> 
          target
      else
        ->
          $("@#{ target }").pi()


  # Global Event Dispatcher

  pi.event = new pi.EventDispatcher()

  utils.extend(
    Nod::, 
    pi: -> @data(pi.API_DATA_KEY),
    piecify: -> pi.piecify @
    )

  # handle all pi clicks

#  $ ->
#    $('body').on 'click', 'a', (e) ->
#      if @getAttribute("href")[0] == "@"
#        utils.debug "handle pi click: #{@getAttribute('href')}"
#        pi.str_to_fun(@getAttribute("href"), $(e.target).pi())()
#        e.preventDefault()
#        e.stopImmediatePropagation()
#      return

   # export functions 
  context.curry = utils.curry
  context.delayed = utils.delayed
  context.after = utils.after
  context.debounce = utils.debounce

  return