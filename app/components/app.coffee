do (context = this) ->
  "use strict"

  # shortcuts
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  class pi.App
    # uppermost component
    view: null
    initialize: ->
      return unless @view?
      view.piecify() 

  pi.app = new pi.App()