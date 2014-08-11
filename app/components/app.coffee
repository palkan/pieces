do (context = this) ->
  "use strict"

  # shortcuts
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  class pi.App
    # uppermost component
    view: null
    initialize: (nod) ->
      @view = pi.piecify(nod || pi.Nod.root)

  pi.app = new pi.App()