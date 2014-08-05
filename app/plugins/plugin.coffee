do(context=this) ->
  "use strict"

  pi = context.pi || {}
  utils = pi.utils

  class pi.Plugin extends pi.Core
    @included: (obj) ->
      snake_name = utils.snake_case @class_name()
      obj["has_#{snake_name}"] = true