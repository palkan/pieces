'use strict'
pi = require '../core'
Context = require './context'
utils = pi.utils
History = require '../core/utils/history'

# Page is a main context with OneByOne strategy by default
# You can overwrite strategy in config (config.page.strategy)
class pi.controllers.Page extends Context
  constructor: ->
    super(strategy: (pi.config.page?.strategy ? 'one_by_one'))

pi.app.page = new pi.controllers.Page()

pi.Compiler.modifiers.push (str) -> 
  if str[0..1] is '@@'
    str = "@app.page.context." + str[2..]
  str

module.exports = pi.controllers.Page
