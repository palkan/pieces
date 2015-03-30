'use strict'
pi = require '../core'
pi.resources = {}

#shortcut
pi.export(pi.resources,"$r")

require './base'
require './view'
require './association'
require './rest'
require './modules'
module.exports = pi.resources