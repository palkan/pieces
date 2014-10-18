'use strict'
pi = require '../../core'
require '../../components/base'
utils = pi.utils

class pi.ProgressBar extends pi.Base
  start: (target) ->
    @value = 0
    @show()

  set: (value) ->
    @value = value
    @style(width: "#{value}%")

  simulate: (speed = 200)->
    @_sid = utils.after speed, =>
              @set (@value + (100 - @value)/2) 
              @simulate(speed)
  reset: ->
    @_sid && clearTimeout(@_sid)
    @style(width: 0)
    @hide()

  stop: ->
    @_sid && clearTimeout(@_sid)
    @style(width: "101%")
    @_sid = utils.after 200, =>
      @style(width: 0)
      @hide()

  dispose: ->
    @_sid && clearTimeout(@_sid)
    super