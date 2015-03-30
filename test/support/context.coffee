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

class pi.controllers.Test2 extends pi.controllers.Base
  submit: (data) ->
    @exit title: data

class pi.controllers.TestPreload extends pi.controllers.Base
  preload: ->
    new Promise((resolve, reject) =>
      @preloaded = true
      pi.utils.after 200, resolve
    )

class pi.controllers.Base.HasResource extends pi.Core
  @mixedin: (owner) ->
    res_name = owner.options.modules.has_resource
    throw Error("Undefined resource: #{res_name}") if !res_name || !(res = utils.obj.get_class_path(pi.resources, res_name))
    owner.resource = res

class pi.views.Test extends pi.views.Base
  default_controller: pi.controllers.Test 

  activated: (data) ->
    if data?.title?
      @title.text data.title 

class pi.views.TestPreload extends pi.views.Base
  default_controller: pi.controllers.Test2 

  activated: (data) ->
    if data?.title?
      @input_txt.value data.title 

  unloaded: ->
    @input_txt?.clear()

class pi.views.Base.Loadable extends pi.Core
  load: (flag = true) ->
    @loader.text (if flag then 'loading' else '')
    