'use strict'
pi = require '../../core'
require '../../components/pieces'
require '../plugin'
utils = pi.utils
# [Plugin]
# Add ability to 'select' element  - toggle 'is-selected' class and trigger 'selected' event 

class pi.Base.Selectable extends pi.Plugin
  id: 'selectable'
  initialize: (@target) ->
    super
    @__selected__ = @target.hasClass 'is-selected'
    @target.on 'click', @click_handler()
    return

  click_handler: ->
    @_click_handler ||= (e) =>
      return unless @target.enabled
      @toggle_select()
      false

  toggle_select: ->
    if @__selected__ then @deselect() else @select()

  select: ->
    unless @__selected__
      @__selected__ = true
      @target.addClass 'is-selected'
      @target.trigger 'selected', true
    @

  deselect: ->
    if @__selected__
      @__selected__ = false
      @target.removeClass 'is-selected'
      @target.trigger 'selected', false
    @