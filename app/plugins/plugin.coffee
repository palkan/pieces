'use strict'
Core = require '../core/core'
utils = require '../core/utils'

class Plugin extends Core
  # uniq plugin id
  id: ""
  # invoked when plugin included to class
  @included: (klass) ->
    self = @
    klass.after_initialize -> @attach_plugin self 
  
  # invoked when plugin attached to instance
  @attached: (instance) ->
    (new @()).initialize instance

  initialize: (instance) ->
    instance[@id] = @
    instance["has_#{@id}"] = true
    instance.addClass "has-#{@id}"
    @

  dispose: utils.truthy

module.exports = Plugin
