do (context = this) ->
  "use strict"

  # shortcuts
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  pi.NodEvent.register_alias 'mousewheel', 'DOMMouseScroll'