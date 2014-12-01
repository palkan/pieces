'use strict'
pi = require '../core'
require './base'
utils = pi.utils

# Main controller 
class pi.controllers.Page extends pi.controllers.Base

pi.app.page = new pi.controllers.Page()

pi.Compiler.modifiers.push (str) -> 
  if str[0..1] is '@@'
    str = "@app.page.context." + str[2..]
  str