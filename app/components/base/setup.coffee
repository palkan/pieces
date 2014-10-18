'use strict'
pi = require '../../core'
require './initializer'
require './klass'
utils = pi.utils

# extend pi.Nod with special query matcher
utils.extend pi.Nod::,
  find_cut: (selector) ->
    rest = []
    acc = []

    el = @node.firstChild
      
    while(el)
      if el.nodeType != 1
        el = el.nextSibling || rest.shift()
        continue
      
      if el.matches(selector)
        acc.push el
      else        
        el.firstChild && rest.unshift(el.firstChild)

      el = el.nextSibling || rest.shift()        
  
    acc


# shortcut to initialize component on nod
pi.piecify = (nod,host) ->
  pi.ComponentInitializer.init nod, host||nod.parent(pi.klass.PI)


# Global Event Dispatcher
pi.event = new pi.EventDispatcher()

# return component by its path (relative to app.view)
# find('a.b.c') -> app.view.a.b.c
pi.find = (pid_path, from) ->
  utils.get_path pi.app.view, pid_path

utils.extend(
  pi.Nod::, 
  piecify: (host) -> pi.piecify @, host
  pi_call: (target, action) ->
    if !@_pi_call or @_pi_action != action
      @_pi_action = action
      @_pi_call = pi.Compiler.str_to_fun action, target
    @_pi_call.call null
  )

# handle all pi clicks
pi.Nod.root.ready ->
  pi.Nod.root.listen(
    'a', 
    'click', 
    (e) ->
      if e.target.attr("href")[0] == "@"
        e.cancel()
        utils.debug "handle pi click: #{e.target.attr("href")}"
        e.target.pi_call e.target, e.target.attr("href")
      return
    )

# magic function
pi.$ = (q) ->
  if q[0] is '@'
    pi.find q[1..]
  else if utils.is_html q
    pi.Nod.create q
  else
    pi.Nod.root.find q

# export pi.$ to global scope
pi.export(pi.$, '$')