'use strict'
pi = require 'pi'
TestHelpers = require '../helpers'
pi.log_level = "debug"

class pi.Testo extends pi.resources.Base
  @set_resource 'testos'


class pi.Salt extends pi.resources.Base
  @set_resource 'salts'


class pi.TestoRest extends pi.resources.REST
  @set_resource 'testos'
  @routes_scope 'test/:path.json'
  @routes collection: [action: 'destroy_all', path: ':resources', method: 'delete']
  @params 'type', {flour: ['id', 'weight', {rye: ['type']} ]}, {salt: ['id', 'salinity']}

  @before_save -> @type||='normal'

  knead: ->
    @_is_kneading = true


## RVC ##

class pi.resources.TestUsers extends pi.resources.REST
  @set_resource 'users'
  @extend pi.resources.Query 
  @params 'name','age'
  
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

class pi.controllers.Test4 extends pi.controllers.ListController
  @list_resource pi.resources.TestUsers
  id: 'test'

  @include pi.controllers.Paginated

  per_page: 5

  page_resolver: (data)->
    if !data.next_page
      @scope().all_loaded()

  initialize: ->
    super

  load: (data) ->
    super

class pi.TestView extends pi.ListView
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

module.exports = TestHelpers