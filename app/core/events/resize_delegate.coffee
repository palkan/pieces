'use strict'
utils = require '../utils'
EventListener = require('./events').EventListener
Core = require('../core')
Nod = require('../nod').Nod
NodEvent = require('../nod').NodEvent

class ResizeListener extends EventListener
  constructor: (@nod, @handler) ->
    @_w = @nod.width()
    @_h = @nod.height()

    _filter = (e) =>
      if @_w != e.width or @_h != e.height
        @_w = e.width
        @_h = e.height
        true
      else
        false
    super 'resize', @handler, @nod, false, _filter
    
class ResizeDelegate extends Core
  constructor: ->
    @listeners = []

  add: (nod, callback) ->
    @listeners.push (new ResizeListener(nod, callback))
    if @listeners.length is 1
      @listen()

  remove: (nod) ->
    flag = false
    for listener,i in @listeners
      if listener.nod is nod
        flag = true
        break
    if flag is true
      @listeners.splice(i,1)

  listen: ->
    NodEvent.add Nod.win.node, 'resize', @resize_listener()

  off: ->
    NodEvent.remove Nod.win.node, 'resize', @resize_listener()

  resize_listener: (e) ->
    for listener in @listeners
      listener.dispatch @_create_event(listener)

  @event_handler 'resize_listener', throttle: 300

  _create_event: (listener) ->
    nod = listener.nod
    {type: 'resize', target: nod, width: nod.width(), height: nod.height()}  

module.exports = ResizeDelegate
