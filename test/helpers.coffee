class pi.TestComponent extends pi.Base
  initialize: ->
    @nod.addClass 'test'
  text: (val = null) ->
    if val? 
      @nod.text val
    else
      @nod.text()

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