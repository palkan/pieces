'use strict'
pi = require '../core'
utils = pi.utils
pi.controllers = {}

app = pi.app

class pi.controllers.Base extends pi.Core

  # add shortcut for resource
  @has_resource: (resource) ->
    return unless resource.resources_name?
    @::[resource.resources_name] = resource

  id: 'base'

  constructor: (@view) ->
    @_initialized = false

  initialize: ->
    @_initialized = true

  load: (context_data) ->
    @initialize() unless @_initialized
    @view.loaded context_data.data
    return

  reload: (context_data) ->
    @view.reloaded context_data.data
    return

  switched: ->
    @view.switched()
    return

  unload: ->
    @view.unloaded()
    return

  exit: (data) ->
    app.page.switch_back data

  switch: (to, data) ->
    app.page.switch_context @id, to, data