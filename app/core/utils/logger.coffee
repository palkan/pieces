'use strict'
pi = require '../pi'
utils = require './base'
require './browser'
require './time'

info = utils.browser.info()

_formatter = 
  if info.msie
    (level, args) ->
      console.log("[#{level}]",args)
      return
  else if window.mochaPhantomJS
    (level, args) ->
      return
  else
    (level, messages) ->
      console.log("%c #{ utils.time.now('%H:%M:%S:%L') } [#{ level }]", "color: #{_log_levels[level].color}", messages)
      return


if !window.console || !window.console.log
  window.console =
    log: -> return

pi.log_level ||= "info"

_log_levels =
  error:
    color: "#dd0011"
    sort: 4
  debug:
    color: "#009922"
    sort: 0
  debug_verbose:
    color: "#eee"
    sort: -1
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

module.exports = utils.log
