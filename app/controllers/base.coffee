'use strict'
Context = require './context'
utils = require '../core/utils'

class Base extends Context
  id: 'base'

  constructor: (options) ->
    super(options)
    @init_modules()

  set_view: (@view) ->
    @view.controller = @
    @

  init_modules: (modules) ->
    @mixin(@constructor.lookup_module(mod)) for mod, _ of @options.modules

  load: (data={}) ->
    promise = super
    @view.loaded(data.params)
    promise

  activate: (data={}) ->
    @view.activated data.params
    return

  deactivated: ->
    @view.deactivated()
    return

  unload: ->
    @view.unloaded()
    return

  exit: (data) ->
    @host_context.switch_back data

  switch: (to, data) ->
    @host_context.switch_context @id, to, data

module.exports = Base
