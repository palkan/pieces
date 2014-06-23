class pi.TestComponent extends pi.Base
  initialize: ->
    super
    @addClass 'test'
    @btn = @find('.btn')

this.TestHelpers = 
  mouseEventElement: (el,type) ->
    ev = document.createEvent "MouseEvent"
    ev.initMouseEvent(
      type,
      true, #bubble 
      true, #cancelable
      window, null,
      0, 0, 0, 0, # coordinates
      false, false, false, false,  # modifier keys 
      0 # left
      null
    )
    el.dispatchEvent ev 
    return
  clickElement: (el) ->
    TestHelpers.mouseEventElement el, "click"
    return

  scrollEvent: (el) ->
    ev = document.createEvent "Event"
    ev.initEvent(
      'scroll',
      true, #bubble 
      true #cancelable
    )
    el.dispatchEvent ev 