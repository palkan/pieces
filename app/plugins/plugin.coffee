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
  @attached: (instance, options={}) ->
    (new @()).initialize instance, options

  initialize: (@target, @options) ->
    @target[@id] = @
    @target["has_#{@id}"] = true
    @target.addClass "has-#{@id}"
    @

  dispose: utils.truthy

module.exports = Plugin
