'use strict'
pi = require '../core'

pi.controllers = {}

#shortcut
pi.export(pi.resources,"$c")

require './context'
require './page'
require './base'
require './initializer'
module.exports = pi.controllers
