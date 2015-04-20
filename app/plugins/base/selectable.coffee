'use strict'
Base = require '../../components/base'
Klass = require '../../components/utils/klass'
Events = require '../../components/events'
Plugin = require '../plugin'
utils = require '../../core/utils'

# Add ability to 'select' element  - toggle 'is-selected' class and trigger 'selected' event 
class Base.Selectable extends Plugin
  id: 'selectable'
  initialize: ->
    super
    Base.active_property @target, 'selected',
      type: 'bool'
      default: (@target.hasClass(Klass.SELECTED))
      event: Events.Selected
      class: Klass.SELECTED
      functions: ['select', 'deselect']
      toggle_select: 'toggle_select'
    @target.on 'click', @click_handler()
    @

  click_handler: (e) ->
    return unless @target.enabled
    @toggle_select()
    false

  @event_handler 'click_handler'

module.exports = Base.Selectable
