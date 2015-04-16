'use strict'
utils = require '../../core/utils'
BindListener = require('../../core/binding').BindListener
Events = require('../events')
Base = require('../base')
Core = require '../../core/core'

class ComponentBind extends Core
  handle_component: (target, name, root, last) ->
    utils.debug 'component', target, name, root, last

    if root
      @listeners.push.apply(@listeners, target.on(Events.Destroyed, => @dispose()))
    else
      @listeners.push.apply(@listeners,  target.on(Events.Destroyed, @_disable)) if target?

    return true if last

    if target.__prop_desc__[name]
      utils.debug 'bindable', target, name
      @listeners.push.apply(@listeners, target.on("change:#{name}", @_update))
    else if !target[name]?
      utils.debug 'create', target, name
      @listeners.push.apply(@listeners, target.on(Events.ChildAdded, @_init, target, (e) -> e.data.pid is name))
      @failed++
      return
    true

BindListener.prepend_type(
  'component',
  (target) -> target instanceof Base
)

BindListener.include ComponentBind

module.exports = BindListener
