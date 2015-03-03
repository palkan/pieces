'use strict'
pi = require '../core'
Context = require './context'
utils = pi.utils

class pi.controllers.Base extends Context
  id: 'base'

  constructor: (options, @view) ->
    super(options)

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

module.exports = pi.controllers.Base
