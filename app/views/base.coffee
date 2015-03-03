'use strict'
pi = require '../core'
utils = require '../core/utils'
require '../components/base'

utils.extend pi.Base::,
  # return view for component
  view: ->
    (@__view__ ||= @_find_view())
  
  # return context (controller) for component
  context: ->
    (@__controller__ ||= @view()?.controller)

  _find_view: ->
    comp = @host
    while(comp)
      if comp.is_view is true
        return comp
      comp = comp.host

class pi.BaseView extends pi.Base
  is_view: true
  
  initialize: ->
    super
    controller_klass = null
    if @options.controller
      controller_klass = utils.obj.get_class_path pi.controllers, @options.controller

    controller_klass ||= @default_controller

    if controller_klass?
      @controller = new controller_klass({}, @)
    else
      utils.warning "controller not found", controller_klass

  postinitialize: ->
    super
    if @controller?
      host_controller = if (_view = @view()) then _view.controller else pi.app.page
      host_controller.add_context @controller, @options

  loaded: (data) ->
    return

  activated: (data) ->
    return

  deactivated: ->
    return

  unloaded: ->
    return

module.exports = pi.BaseView
