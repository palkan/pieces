'use strict'
pi = require '../core'
require '../components/pieces'
utils = pi.utils

utils.extend pi.Base::,
  view: ->
    (@__view__ ||= @_find_view())

  _find_view: ->
    comp = @host
    while(comp)
      if comp.is_view is true
        return comp
      comp = comp.host

class pi.BaseView extends pi.Base
  is_view: true
    
  initialize: ->
    controller_klass = null
    if @options.controller
      controller_klass = utils.get_class_path pi.controllers, @options.controller

    controller_klass ||= @default_controller

    if controller_klass?
      @controller = new controller_klass(@)
    else
      utils.warning "controller not found", controller_klass

    super

  postinitialize: ->
    super
    if @controller?
      host_controller = if (_view = @view()) then _view.controller else pi.app.page
      host_controller.add_context @controller, @options.main

  loaded: (data) ->
    return

  reloaded: (data) ->
    return

  switched: ->
    return

  unloaded: ->
    return
