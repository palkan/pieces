'use strict'

utils = pi.utils

class pi.controllers.TestContext extends pi.controllers.Context
  load: (@data) ->
    super
    @state = 'loaded'

  unload: ->
    super
    @state = 'unloaded'

  activate: (@data) ->
    @state = 'activated'

  deactivate: ->
    @state = 'deactivated'

  clear: ->
    delete @state
    delete @data
    @_initialized = false


class pi.controllers.SlowContext extends pi.controllers.TestContext
  preload: ->
    if @_initialized
      utils.promise.resolved()
    else
      utils.promise.delayed(Math.random()*500)

class pi.controllers.Test extends pi.controllers.Base
  id: 'test'

class pi.controllers.Test2 extends pi.controllers.Base
  id: 'test2'

  submit: (data) ->
    @exit title: data

class pi.controllers.TestPreload extends pi.controllers.Base
  id: 'test_preload'

  preload: ->
    new Promise((resolve, reject) =>
      @preloaded = true
      pi.utils.after 200, resolve
    )


class pi.TestView extends pi.BaseView
  default_controller: pi.controllers.Test 

  reloaded: (data) ->
    if data?.title?
      @title.text data.title 

class pi.Test2View extends pi.BaseView
  default_controller: pi.controllers.Test2 

  reloaded: (data) ->
    if data?.title?
      @input_txt.value data.title 

  unloaded: ->
    @input_txt?.clear()
    