'use strict'
pi = require '../pi'
require './base'
require './browser'
require './time'

utils = pi.utils 
info = utils.browser.info()

_formatter = 
  if info.msie
    (level, args) ->
      console.log("[#{level}]",args)
  else if window.mochaPhantomJS
    (level, args) ->
      null
  else
    (level, messages) ->
      console.log("%c #{ utils.time.now('%H:%M:%S:%L') } [#{ level }]", "color: #{_log_levels[level].color}", messages)


if !window.console || !window.console.log
  window.console =
    log: ->
      true

pi.log_level ||= "info"

_log_levels =
  error:
    color: "#dd0011"
    sort: 4
  debug:
    color: "#009922"
    sort: 0
  info:
    color: "#1122ff"
    sort: 1
  warning: 
    color: "#ffaa33"
    sort: 2

_show_log =  (level) ->
  _log_levels[pi.log_level].sort <= _log_levels[level].sort


utils.log = (level, messages...) ->
  _show_log(level) && _formatter(level, messages)
#log levels aliases

(utils[level] = utils.curry(utils.log,level)) for level,val of _log_levels 