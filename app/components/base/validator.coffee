'use strict'
pi = require '../../core'
require './base_input'
utils = pi.utils

_type_rxp = /(\w+)(?:\(([\w\-\/]+)\))/

class pi.BaseInput.Validator
  @add: (name, fun) ->
    @[name] = fun

  @validate: (type, nod, form) ->
    if(matches = type.match(_type_rxp))
      type = matches[1]
      data = utils.serialize matches[2]
    @[type] nod.value(), nod, form, data

  @email: (val) ->
    utils.is_email val

  @len: (val, nod, form, data) ->
    (val+"").length >= data

  @truth: (val) ->
    !!utils.serialize(val)

  @presence: (val) ->
    val && ((val+"").length > 0)

  @digital: (val) ->
    utils.is_digital (val+"")

  # validates that form contains another input with name '<name>_confirmation'
  # and its value eqauls to val
  # Works with Rails names: user[password] -> user[password_confirmation]
  @confirm: (val, nod, form) ->
    confirm_name = nod.name().replace(/([\]]+)?$/,"_confirmation$1")
    conf_nod = form.find_by_name confirm_name
    unless conf_nod?
      return false
    return conf_nod.value() is val 

module.exports = pi.BaseInput.Validator
