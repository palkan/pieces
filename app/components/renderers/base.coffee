'use strict'
pi = require '../../core'
utils = pi.utils

pi.Renderers = {}

class pi.Renderers.Base
  render: (nod) ->
    return unless nod instanceof pi.Nod
    @_render nod, nod.data() 

  _render: (nod, data) ->
    unless nod instanceof pi.Base
      nod = nod.piecify()
    nod.record = data
    nod