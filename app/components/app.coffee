do (context = this) ->
  "use strict"

  # shortcuts
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  class pi.App
    initialize: (nod) ->
      @view = pi.piecify(nod || pi.Nod.root)
      @page?.initialize()

  pi.app = new pi.App()