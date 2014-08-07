do(context=this) ->
  "use strict"

  pi = context.pi || {}
  utils = pi.utils

  class pi.Plugin extends pi.Core

    # invoked when plugin included to class (pi.Base)
    @included: (klass) ->
      self = @
      klass.before_create -> @attach_plugin self 
    
    # invoked when plugin attached to instance
    @attached: (instance) ->
      (new @()).initialize instance

    initialize: (instance) ->
      snake_name = utils.snake_case @class_name()
      instance[snake_name] = @
      instance["has_#{snake_name}"] = true
