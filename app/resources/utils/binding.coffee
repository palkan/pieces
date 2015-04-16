'use strict'
utils = require '../../core/utils'
BindListener = require('../../core/binding').BindListener
Events = require('../events')
Base = require('../base')
View = require('../view')
Core = require '../../core/core'

class ResourceBind extends Core
  handle_resource_view: (target, name, _root, last) ->
    @listeners.push.apply(@listeners, target.listen(@_update)) if target?
    true

  handle_resource: (target, name, root = false) ->
    utils.debug 'resource', target, name, root
    if root
      @listeners.push.apply(@listeners, target.on(Events.Destroy, => @dispose()))
    else
      @listeners.push.apply(@listeners,  target.on(Events.Destroy, @_disable)) if target?

    @listeners.push.apply(@listeners, target.on([Events.Update, Events.Create], @_update)) if target?
    true

BindListener.prepend_type(
  'resource',
  (target) -> (target instanceof Base) || (target instanceof View.ViewItem)
)

BindListener.prepend_type(
  'resource_view',
  (target) -> target instanceof View
)

BindListener.include ResourceBind

module.exports = BindListener
