'use strict'

class pi.Nod.Renameable
  @included: ->
  world: (name = "my world") ->
    name

class pi.Core.Helloable
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
  @include pi.Nod.Renameable

class pi.Test3 extends pi.Test
  @include pi.Nod.Renameable, pi.Core.Helloable