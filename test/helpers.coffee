class pi.TestComponent extends pi.Base
  initialize: ->
    super
    @addClass 'test'
    @btn = new pi.Base @find('.btn')?.node

  name: (val) ->
    if val?
      @options.name = val
    else
      @options.name || 'test'

  value_trigger: (val)->
    @trigger "value", val

class pi.TestComponent.Renameable extends pi.Plugin
  world: (name = "my world") ->
    name

class pi.Base.Helloable extends pi.Plugin
  hello: (phrase = "ciao") ->
    phrase

class pi.Test extends pi.Core
  @alias "hallo", "hello"
   
  hello: ->
    "hello"
  world: ->
    "world"

  hello_world: ->
    "#{@hello()} #{@world()}"

class pi.Test2 extends pi.Test
  @include pi.TestComponent.Renameable

class pi.Test3 extends pi.Test
  @include pi.TestComponent.Renameable, pi.Base.Helloable


this.TestHelpers = 
  mouseEventElement: (el,type, x=0, y=0) ->
    ev = document.createEvent "MouseEvent"
    ev.initMouseEvent(
      type,
      true, #bubble 
      true, #cancelable
      window, null,
      0, 0, x, y, # coordinates
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