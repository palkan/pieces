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
    comp = @
    while(comp)
      if comp.is_view is true
        return comp
      comp = comp.host

class pi.views.Base extends pi.Base
  is_view: true
  
  initialize: ->
    super

  postinitialize: ->
    @init_modules()
    super

  init_modules: ->
    @mixin(@constructor.lookup_module(mod)) for mod, _ of @options.modules

  loaded: (data) ->
    return

  activated: (data) ->
    return

  deactivated: ->
    return

  unloaded: ->
    return

module.exports = pi.views.Base
