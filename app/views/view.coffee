'use strict'
pi = require 'core'
require 'components/pieces'
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
