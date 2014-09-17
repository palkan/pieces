'use strict'
pi = require '../../core'
require '../../components/base/list'
require '../plugin'
utils = pi.utils

# [Plugin]
# Dispatch 'scroll_end' event when list is scrolled to bottom
class pi.List.ScrollEnd extends pi.Plugin
  id: 'scroll_end'
  initialize: (@list) ->
    super
    @scroll_object = if @list.options.scroll_object == 'window' then pi.Nod.win else @list.items_cont
    @_prev_top = @scroll_object.scrollTop()

    @enable() unless @list.options.scroll_end is false
    @list.on 'update', @scroll_listener(), @, (e) => (e.data.type is 'item_removed' or e.data.type is 'load') 
    @list.on 'destroyed', =>
      @disable()
    return

  enable: () ->
    return if @enabled

    @scroll_object.on 'scroll', @scroll_listener() 
    @enabled = true

  disable: () ->
    return unless @enabled
    @.__debounce_id__ && clearTimeout(@__debounce_id__)
    @scroll_object.off 'scroll', @scroll_listener()
    @_scroll_listener = null      
    @enabled = false

  scroll_listener: () ->
    @_scroll_listener ||= utils.debounce 500, ((event) =>
      return if @list._disposed
      if @_prev_top <= @scroll_object.scrollTop() and @list.height() - @scroll_object.scrollTop() - @scroll_object.height()  < 50
        @list.trigger 'scroll_end'
      @_prev_top = @scroll_object.scrollTop()), @