'use strict'
EventDispatcher = require('../../core/events').EventDispatcher
Nod = require('../../core/nod').Nod
Initializer = require './initializer'
Klass = require './klass'
Compiler = require '../../grammar/compiler'
utils = require '../../core/utils'
App = require '../../core/app'

# shortcut to initialize component on nod
piecify = (nod, host) ->
  Initializer.init nod, host||nod.parent(Klass.PI)

# Global Event Dispatcher
EventDispatcher.Global = new EventDispatcher()

# Document
Nod.root = new Nod.Root()
Nod.root.initialize()

# return component by its path (relative to app.view)
# find('a.b.c') -> app.view.a.b.c
find = (pid_path, from) ->
  utils.obj.get_path window.pi.app.view, pid_path

utils.extend(
  Nod::, 
  piecify: (host) -> piecify @, host
  pi_call: (target, action) ->
    if !@_pi_call or @_pi_action != action
      @_pi_action = action
      @_pi_call = Compiler.str_to_fun action, target
    @_pi_call.call null
  )

# handle all pi clicks
Nod.root.ready().then( ->
  Nod.root.listen(
    'a', 
    'click', 
    (e) ->
      if (href = e.target.attr("href")) and href[0] is "@"
        e.cancel()
        utils.debug "handle pi click: #{e.target.attr("href")}"
        e.target.pi_call e.target, e.target.attr("href")
      return
    )
)

# magic function
$ = (q) ->
  if q[0] is '@'
    find q[1..]
  else if utils.is_html q
    Nod.create q
  else
    Nod.root.find q

for method in ['ready', 'loaded']
  do(method) ->
    $[method] = (callback) ->
      Nod.root[method](callback)

module.exports = $
