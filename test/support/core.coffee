'use strict'

class Renameable
  world: (name = "my world") ->
    name

class Helloable
  hello: (phrase = "ciao") ->
    phrase

class Enablable
  @extended: (base) ->
    base.getter 'enabled', (-> @_enabled), true
  
  @enable: ->
    @_enabled = true

class pi.Test extends pi.Core
  @getter 'inited', -> @_inited
  @getset 'available', (-> @_available), ((val) -> @_available = !!val), true

  @make_available: ->
    @available = true

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
  @class_alias "enable", "make_available"
  @register_callback 'init'

class pi.Test4 extends pi.Test
  @after_init () -> @my_name += ' 2'

class pi.Test2 extends pi.Test
  @include Renameable
  @extend Enablable

class pi.Test3 extends pi.Test
  @include Renameable, Helloable