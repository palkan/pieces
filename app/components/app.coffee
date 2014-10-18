'use strict'
pi = require '../core/pi'

utils = pi.utils

class pi.App
  initialize: (nod) ->
    @view = pi.piecify(nod || pi.Nod.root)
    @page?.initialize()

pi.app = new pi.App()
module.exports = pi.app