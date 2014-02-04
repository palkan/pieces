do (context = this) ->
  "use strict"


  # shortcuts

  $ = context.jQuery
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  pi.API_DATA_KEY = "js_piece"

  class pi.Base extends pi.EventDispatcher

    constructor: (target, @options = {}) ->
      super
      @visible = @enabled = true
      @init_nod target
      @init_plugins()
      @disable() if @options.disabled
      @hide() if @options.hidden
      @value = @nod.data('value') || @nod.val()
      @nod.data(pi.API_DATA_KEY, this)
      @initialize()
      @setup_events()

    init_nod: (target) ->
      if typeof target is "string"
        @nod = $(target)
      else if target instanceof $
        @nod = target
      else
        @nod = $(target)
    
    init_plugins: ->
      if @options.plugins?
        attach_plugin name for name in @options.plugins
        
    attach_plugin: (name) ->
      name = utils.camelCase name
      if pi[name]?
        new pi[name] this


    ## internal ##

    initialize: -> 
      @_initialized = true

    native_events:
      ["click", "focus", "blur", "change", "scroll", "select", "mouseover", "mouseout", "mousemove", "mouseup", "mousedown", "mouseenter", "mouseleave", "resize", "keydown", "keypress", "keydown"]

    event_is_native: (event) ->
      @native_events.indexOf(event) > -1

    native_event_listener: (event) ->
      @trigger event

    setup_events: ->
      for event, handler of @options.events
        @on event, pi.str_to_fun(handler)

    changed: (property) ->
      @trigger property, this[property]
      return

    ## event dispatcher ##

    on: (event, callback, context) ->
      if !@listeners[event]? and @event_is_native(event) and @nod?
        @nod.on event, @native_event_listener.bind(this)
      super event, callback, context

    one: (event, callback, context) ->
      if !@listeners[event]? and @event_is_native(event) and @nod?
        @nod.on event, @native_event_listener.bind(this)
      super event, callback, context

    off: (event, callback, context) ->
      super event, callback, context
      if !@listeners[event]? and @event_is_native(event) and @nod?
        @nod.off event
      else if not event?
        @nod.off()

    remove_type: (event) ->
      super event
      @nod.off event if @event_is_native(event) and @nod?

    ## public interface ##

    show: -> 
      if not @visible
        @nod.removeClass 'hidden'
        @visible = true
        @changed 'visible'

    hide: ->
      if @visible
        @nod.addClass 'hidden'
        @visible = false
        @changed 'visible'

    enable: ->
      if not @enabled 
        @nod.removeClass 'disabled'
        @nod.get(0).removeAttribute('disabled')
        @enabled = true
        @changed 'enabled'

    disable: ->
      if @enabled
        @nod.addClass 'disabled'
        @nod.get(0).setAttribute('disabled', 'disabled')
        @enabled = false
        @changed 'enabled'

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
    component_name = utils.camelCase(nod.data('component'))
    component = pi[component_name]

    if component? and not nod.data(pi.API_DATA_KEY)
      new pi[component_name](nod,pi.gather_options(nod))
    else
      throw new ReferenceError('unknown or initialized component: ' + component_name)
    

  pi.piecify = (context) ->
    context = if context instanceof $ then context else $(context || document)
    pi.init_component($(nod)) for nod in context.find(".pi")
  
  pi.gather_options = (el) ->
    el = if el instanceof $ then el else $(el)

    opts =
      component: el.data('component')                
      plugins: if el.data('plugins') then el.data('plugins').split(/\s+/) else null
      events: {}

    for key,val of el.data()
      if matches = key.match options_re
        opts[utils.snakeCase(matches[1])] = val
        continue
      if matches = key.match event_re
        opts.events[utils.snakeCase(matches[1])] = val

    opts

  pi.call = (component, method, args = []) ->   
    try
      target = $("@#{ component }").pi()
      target[method].apply(target, args)
    catch error
      utils.error error

  pi.str_to_fun = (callstr) ->
    matches = callstr.match(/@([\w\d_]+)\.([\w\d_]+)(?:\s+([\w\d,]+))?/)
    curry(pi.call,[matches[1], matches[2], (if matches[3] then (utils.serialize(arg) for arg in matches[3].split(",")) else [])])


  $.extend(
    $.fn, 
    pi: -> this.data(pi.API_DATA_KEY),
    piecify: -> pi.piecify(this)
    )

  # handle all pi clicks

  $ ->
    $('body').on 'click', 'a', (e) ->
      if @getAttribute("href")[0] == "@"
        e.preventDefault()
        pi.str_to_fun(@getAttribute("href"))()
      return

  return