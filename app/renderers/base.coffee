'use strict'
Nod = require('../core/nod').Nod
utils = require('../core/utils')
BaseComponent = require('../components/base')

class Base
  render: (nod, piecified, host) ->
    return unless nod instanceof Nod
    @_render nod, nod.data(), piecified, host 

  _render: (nod, data, piecified = true, host) ->
    unless nod instanceof BaseComponent
      nod = nod.piecify(host) if piecified
    nod.record = data
    nod

module.exports = Base
