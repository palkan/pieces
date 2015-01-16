'use strict'
pi = require '../pi'
require '../utils'
require './nod_events'
utils = pi.utils

class pi.NodEvent.ResizeListener extends pi.EventListener
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
    
class pi.NodEvent.ResizeDelegate
  constructor: ->
    @listeners = []

  add: (nod, callback) ->
    @listeners.push (new pi.NodEvent.ResizeListener(nod, callback))
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
    pi.NodEvent.add pi.Nod.win.node, 'resize', @resize_listener()

  off: ->
    pi.NodEvent.remove pi.Nod.win.node, 'resize', @resize_listener()

  resize_listener: ->
    @_resize_listener ||= utils.throttle 300, (e) =>
      for listener in @listeners
        listener.dispatch @_create_event(listener)

  _create_event: (listener) ->
    nod = listener.nod
    {type: 'resize', target: nod, width: nod.width(), height: nod.height()}  

pi.NodEvent.register_delegate('resize', new pi.NodEvent.ResizeDelegate())