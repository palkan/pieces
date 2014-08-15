do (context = this) ->
  "use strict"

  # shortcuts
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  pi.View = {}

  utils.extend pi.Base::,
    view: ->
      (@__view__ ||= @_find_view())
    _find_view: ->
      comp = @
      while(comp)
        if comp instanceof pi.View.Base
          return comp
        comp = comp.host

  class pi.View.Base extends pi.Base
    @requires: (components...) ->
      @before_create ->
        while(components.length)
          cmp = components.pop()
          if @[cmp] is undefined
            throw Error("Missing required component #{cmp}") 

    postinitialize: ->
      controller_klass = null
      if @options.controller
        controller_klass = utils.get_class_path pi.controllers, @options.controller

      controller_klass ||= @default_controller

      if controller_klass?
        controller = new controller_klass(@)
        pi.app.page.add_context controller, @options.main

    loaded: (data) ->
      return

    unloaded: ->
      return
