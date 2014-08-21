'use strict'
pi = require '../../core'
require './../base'
utils = pi.utils

# [Plugin]
# Add 'loading' method to control loader
class pi.BaseView.Loadable
  @included: (klass) ->
    klass.requires 'loader'

  loading: (value) ->
    if value is true
      @loader.reset()
      @loader.start()
      @loader.simulate()
    else if value is false
      @loader.stop()