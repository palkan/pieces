'use strict'
pi = require 'core/pi'
require './pieces' 

utils = pi.utils

class pi.App
  initialize: (nod) ->
    @view = pi.piecify(nod || pi.Nod.root)
    @page?.initialize()

pi.app = new pi.App()
module.exports = pi.app