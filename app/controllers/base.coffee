'use strict'
pi = require 'core'
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

  load: (data) ->
    @initialize() unless @_initialized
    @view.loaded data
    return

  unload: ->
    @view.unloaded()
    return

  exit: (data) ->
    app.page.switch_back data

  switch: (to, data) ->
    app.page.switch_context @id, to, data