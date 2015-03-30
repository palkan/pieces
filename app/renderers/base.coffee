'use strict'
pi = require '../core'
utils = pi.utils

class pi.Renderers.Base
  render: (nod, piecified, host) ->
    return unless nod instanceof pi.Nod
    @_render nod, nod.data(), piecified, host 

  _render: (nod, data, piecified = true, host) ->
    unless nod instanceof pi.Base
      nod = nod.piecify(host) if piecified
    nod.record = data
    nod

module.exports = pi.Renderers.Base
