'use strict'
Context = require './context'
utils = require '../core/utils'
Config = require '../core/config'
Compiler = require '../grammar/compiler'

# Page is a main context with OneByOne strategy by default
# You can overwrite strategy in config (config.page.strategy)
class Page extends Context
  @instance: null
  constructor: ->
    @constructor.instance = @
    super(utils.merge({strategy: 'one_for_all', default: 'main'}, Config.page))

Compiler.modifiers.push (str) -> 
  if str[0..1] is '@@'
    str = "@app.page.context." + str[2..]
  str

module.exports = Page
