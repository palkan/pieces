class pi.TestComponent extends pi.Base
  @after_initialize () -> @id = @options.id
  @before_create () -> @on 'click', => @value_trigger(13)

  initialize: ->
    @addClass 'test'
    super

  name: (val) ->
    if val?
      @options.name = val
    else
      @options.name || 'test'

  value_trigger: (val)->
    @trigger "value", val

class pi.TestComponent.Renameable
  @included: ->
  world: (name = "my world") ->
    name

class pi.Base.Helloable
  @included: ->
  hello: (phrase = "ciao") ->
    phrase

class pi.Test extends pi.Core
  hello: ->
    "hello"
  world: ->
    "world"

  init: (@my_name='')->
    @_inited = true
    @

  hello_world: ->
    "#{@hello()} #{@world()}"

  @alias "hallo", "hello"
  @register_callback 'init'

class pi.Test4 extends pi.Test
  @after_init () -> @my_name += ' 2'

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