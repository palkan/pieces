'use strict'
Core = require '../../core/core'
utils = require '../../core/utils'

class AbstractStorage extends Core
  find: -> null
  find_by: -> null
  fetch: -> []
  destroy: (el) -> el
  update: (el, params) -> el.set(params)
  create: @::update

module.exports = AbstractStorage
