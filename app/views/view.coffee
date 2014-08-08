do (context = this) ->
  "use strict"

  # shortcuts
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  pi.View = {}

  utils.extend pi.Base::,
    view: ->
      (@__view__ ||= @_find_view())
    _find_view: ->
      comp = @
      while(comp)
        if comp instanceof pi.View.Base
          return comp
        comp = comp.host

  class pi.View.Base extends pi.Base
    
