'use strict'
pi = require '../core'
utils = pi.utils

class pi.Plugin extends pi.Core
  # uniq plugin id
  id: ""
  # invoked when plugin included to class (pi.Base)
  @included: (klass) ->
    self = @
    klass.after_initialize -> @attach_plugin self 
  
  # invoked when plugin attached to instance
  @attached: (instance) ->
    (new @()).initialize instance

  initialize: (instance) ->
    instance[@id] = @
    instance["has_#{@id}"] = true
