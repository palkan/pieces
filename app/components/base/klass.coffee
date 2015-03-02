'use strict'
pi = require '../../core'

# Class names constants (can be overwritten)
pi.klass =
  PI: 'pi'
  DISABLED: 'is-disabled'
  HIDDEN: 'is-hidden'
  ACTIVE: 'is-active'
  READONLY: 'is-readonly'
  INVALID: 'is-invalid'
  SELECTED: 'is-selected'
  LIST: 'list'
  LIST_ITEM: 'item'
  FILTERED: 'is-filtered'
  SEARCHING: 'is-searching'
  EMPTY: 'is-empty'

module.exports = pi.klass
