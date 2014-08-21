'use strict'
pi = require '../core'
require './base'
utils = pi.utils

class pi.ListView extends pi.BaseView
  @include pi.BaseView.Loadable, pi.BaseView.Listable

  error: (message) ->
    utils.error message

  success: (message) ->
    utils.info message