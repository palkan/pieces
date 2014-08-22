'use strict'
pi = require '../core'
require '../components/pieces'
utils = pi.utils

utils.extend pi.Base::,
  view: ->
    (@__view__ ||= @_find_view())
  _find_view: ->
    comp = @
    while(comp)
      if comp.is_view is true
        return comp
      comp = comp.host

class pi.BaseView extends pi.Base
  is_view: true
  postinitialize: ->
    controller_klass = null
    if @options.controller
      controller_klass = utils.get_class_path pi.controllers, @options.controller

    controller_klass ||= @default_controller

    if controller_klass?
      @controller = new controller_klass(@)
      pi.app.page.add_context @controller, @options.main

  loaded: (data) ->
    return

  reloaded: (data) ->
    return

  switched: ->
    return

  unloaded: ->
    return
