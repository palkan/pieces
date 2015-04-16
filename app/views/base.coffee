'use strict'
utils = require '../core/utils'
BaseComponent = require '../components/base'

class Base extends BaseComponent
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

# Extend Base component
utils.extend BaseComponent::,
  # return context (controller) for component
  context: ->
    (@__controller__ ||= @view()?.controller)

  _find_view: ->
    comp = @
    while(comp)
      if comp.is_view is true
        return comp
      comp = comp.host

BaseComponent.getter 'view', ->
  (@__view__ ||= @_find_view())

module.exports = Base
