'use strict'
pi = require '../../core'
utils = pi.utils

pi.Renderers = {}

class pi.Renderers.Base
  render: (nod, piecified) ->
    return unless nod instanceof pi.Nod
    @_render nod, nod.data(), piecified 

  _render: (nod, data, piecified = true) ->
    unless nod instanceof pi.Base
      nod = nod.piecify() if piecified
    nod.record = data
    nod