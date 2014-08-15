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

pi.Guesser.rules_for 'test_component', ['test']

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


class pi.Testo extends pi.resources.Base
  @set_resource 'testos'


class pi.Salt extends pi.resources.Base
  @set_resource 'salts'


class pi.TestoRest extends pi.resources.REST
  @set_resource 'testos'
  @routes_scope 'test/:path.json'
  @routes collection: [action: 'destroy_all', path: ':resources', method: 'delete']

  knead: ->
    @_is_kneading = true


## RVC ##

class pi.resources.TestUsers extends pi.resources.REST
  @set_resource 'users'
  @extend pi.resources.Query 
  
class pi.controllers.Test extends pi.controllers.ListController
  @list_resource pi.resources.TestUsers
  id: 'test'

class pi.controllers.Test2 extends pi.controllers.Base
  @has_resource pi.Testo  
  id: 'test2'

  submit: (data) ->
    @exit title: data

class pi.controllers.Test3 extends pi.controllers.ListController
  @list_resource pi.resources.TestUsers
  id: 'test'

  initialize: ->
    super

  load: (data) ->
    super

class pi.View.Test extends pi.View.List
  default_controller: pi.controllers.Test 

  loaded: (data) ->
    if data?.title?
      @title.text data.title 

class pi.View.Test2 extends pi.View.Base
  default_controller: pi.controllers.Test2 

  loaded: (data) ->
    if data?.title?
      @input_txt.value data.title 

  unloaded: ->
    @input_txt?.clear()


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

  keyEvent: (nod, type, code) ->
    code = code.charCodeAt(0) if typeof code is 'string'
    ev = document.createEvent "KeyboardEvent"
    ev.initKeyboardEvent(type, true, true, null, 0, false, 0, false, code, 0) 
    nod.native_event_listener ev
    return

  scrollEvent: (el) ->
    ev = document.createEvent "Event"
    ev.initEvent(
      'scroll',
      true, #bubble 
      true #cancelable
    )
    el.dispatchEvent ev 

this.mock_net = ->
  pi._orig_net = pi.net
  pi.net = (pi._mock_net ||= ( ->
    net =
      request: (method, url, data, options) ->
        new Promise(
          (resolve, reject) ->
            req = new XMLHttpRequest()
           
            params = []
            if data?
              params.push("#{ key }=#{ encodeURIComponent(val) }") for own key, val of data
          
            params = "#{ params.join("&") }"

            fake_url="/support/#{ url.replace(/\//g,"_") }"
           
            req.open 'GET', fake_url, true
            
            req.onreadystatechange = ->

              return if req.readyState isnt 4 

              if req.status is 200
                response = JSON.parse req.responseText
                method = method.toLowerCase()
                resolve(if response[method]? then response[method] else response["default"])
              else
                reject Error(req.statusText)
      
            req.onerror = ->
              reject Error("Network Error")
              return
          
            req.send(null)
        )
    net[method] = curry(net.request, [method.toUpperCase()], net) for method in ['get', 'post', 'patch', 'delete']
    net
    )())
  return

this.unmock_net = ->
  pi.net = pi._orig_net