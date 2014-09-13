'use strict'
pi = require '../../core'
require '../../components/pieces'
require '../plugin'
utils = pi.utils
Nod = pi.Nod

# from nanoscroller
SCROLLBAR_WIDTH = (->
  outer = document.createElement 'div'
  outerStyle = outer.style
  outerStyle.position = 'absolute'
  outerStyle.width = '100px'
  outerStyle.height = '100px'
  outerStyle.overflow = 'scroll'
  outerStyle.top = '-9999px'
  document.body.appendChild outer
  scrollbarWidth = outer.offsetWidth - outer.clientWidth
  document.body.removeChild outer
  scrollbarWidth)() 

isFFWithBuggyScrollbar = (->
  ua = window.navigator.userAgent
  isOSXFF = /(?=.+Mac OS X)(?=.+Firefox)/.test(ua)
  return false if not isOSXFF
  version = /Firefox\/\d{2}\./.exec(ua)
  version = version[0].replace(/\D+/g, '') if version
  return isOSXFF and +version > 23)()


class pi.Base.Scrollable extends pi.Plugin
  id: 'scollable'
  initialize: (@pane) ->
    utils.info "Browser scrollWidth is #{SCROLLBAR_WIDTH}"
    @content = @pane.find('.pi-scroll-content')
    unless @content
      @content = pi.Nod.create(@pane.node.children[0]).addClass('pi-scroll-content')
    @track = Nod.create('div').addClass('pi-scroll-track')
    @thumb = Nod.create('div').addClass('pi-scroll-thumb')
    @track.append @thumb
    @pane.append @track
    
    @hide_native_scroller()

    @setup_events()
    @update_thumb()

  hide_native_scroller: ->
    if SCROLLBAR_WIDTH is 0 and isFFWithBuggyScrollbar
      currentPadding = window.getComputedStyle(@pane.node,null).getPropertyValue('padding-right').replace(/[^0-9.]+/g, '')
      cssRule =
        right: "-17px"
        paddingRight: "#{+currentPadding + 17}px"
    else if SCROLLBAR_WIDTH
      cssRule = right: "#{-SCROLLBAR_WIDTH}px"
      @pane.addClass 'has-scrollbar'

    @content.style(cssRule) if cssRule?

  setup_events: ->
    @content.on 'mousewheel', @scroll_listener()
    @thumb.on 'mousedown', @thumb_mouse_down()
    @track.on 'click', @track_click()

  scroll_listener: ->
    @_sl ||= (e) =>
      @update_thumb(e)

  thumb_mouse_down: ->
    @__tmd ||= (e) =>
      @_wait_drag = utils.after 300, =>
        @_startY = e.pageY
        @track.addClass 'is-active'
        @_start_point = @thumb.offset().y
        utils.debug 'start_move'
        @update_scroll()
        pi.Nod.root.on 'mousemove', @track_mouse_move()
        @track.off 'click', @track_click()
        @content.off 'mousewheel', @scroll_listener()
        @_dragging = true
      pi.Nod.root.on 'mouseup', @mouse_up_listener()

  track_mouse_move: ->
    @__tmm ||= (e) =>
      @update_scroll(e)

  track_click: ->
    @_tc ||= (e) =>
      h = @thumb.clientHeight()
      ch = @content.clientHeight()
      track_y = @track.y()
      y = e.pageY - track_y
      if y>ch-h
        y = ch-h
      if y<0
        y=0
      @thumb.style top: "#{y}px"
      @update_scroll()

  mouse_up_listener: ->
    @__mul ||= =>
      @track.removeClass 'is-active'
      clearTimeout @_wait_drag
      utils.debug 'stop_move'
      pi.Nod.root.off 'mousemove', @track_mouse_move()
      pi.Nod.root.off 'mouseup', @mouse_up_listener()
      # set timeout because we don't want this to trigger
      after 500, => @track.on('click', @track_click())
      @content.on 'mousewheel', @scroll_listener()

  update_scroll: (e) ->
    h = @thumb.clientHeight()
    sh = @content.scrollHeight()
    ch = @content.clientHeight()
    st = @content.scrollTop()

    if e?
      y = (e.pageY - @_startY)+@_start_point
      if (y > ch-h) 
        y = ch-h
      if (y<0)
        y = 0 
      @thumb.style top: "#{y}px" 
    else
      y = @thumb.offset().y

    @_last_scroll = (sh - ch)*(y/(ch - h))
    @content.node.scrollTop = @_last_scroll


  update_thumb: (e) ->
    sh = @content.scrollHeight()
    ch = @content.clientHeight()
    st = @content.scrollTop()
    
    @_last_scroll = st

    h = Math.max(20, ch * (ch / sh))
    y = (ch - h)*(st/(sh-ch))

    if (y<0) or (y>ch-h)
      e?.cancel()
      return

    if e?
      e.cancel() if y is 0 and e.wheelDelta > 0
    
    @thumb.style top: "#{y}px", height: "#{h}px"







