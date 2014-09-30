'use strict'
pi = require 'pi'
TestHelpers = require '../helpers'
pi.log_level = "debug"

class pi.Testo extends pi.resources.Base
  @set_resource 'testos'

class pi.Testo2 extends pi.resources.REST
  @set_resource 'testos'

class pi.TestoWrap extends pi.resources.REST
  @set_resource 'testos'
  wrap_attributes: true

class pi.Eater extends pi.resources.REST
  @set_resource 'eaters'
  @params 'name', 'age', 'weight'

class pi.resources.Chef extends pi.resources.REST
  @extend pi.resources.HasMany
  @set_resource 'chefs'

  @has_many 'testos', source: pi.Testo2, belongs_to: true, route: true, attribute: true, destroy: true
  @has_many 'eaters', source: pi.Eater, params: ['kg_eaten'], attribute: true, id_alias: 'eater_id', scope: false

  @params 'name', 'age', 'coolness'


class pi.resources.Testo extends pi.resources.Base
  @set_resource 'testos'

class pi.Salt extends pi.resources.Base
  @set_resource 'salts'


class pi.TestoRest extends pi.resources.REST
  @set_resource 'testos'
  @can_create pi.Salt
  @routes_scope 'test/:path.json'
  @routes collection: [action: 'destroy_all', path: ':resources', method: 'delete']
  @params 'type', {flour: ['id', 'weight', {rye: ['type']} ]}, {salt: ['id', 'salinity']}

  @before_save -> @type||='normal'

  knead: ->
    @_is_kneading = true

class pi.TestoRest2 extends pi.resources.REST
  @set_resource 'testos'
  @routes_scope 'types/:type/test/:path.json'

## RVC ##

class pi.resources.TestUsers extends pi.resources.REST
  @set_resource 'users'
  @extend pi.resources.Query 
  @params 'name','age'


class pi.resources.Meeting extends pi.resources.REST
  @extend pi.resources.HasMany
  @set_resource 'meetings'

  @has_many 'users', source: pi.resources.TestUsers, params: ['role_id'], attribute: true, scope: false, route: true, path: '/users/?filter[age]=:age'
  @params 'name', 'age'
  

class pi.resources.Profile extends pi.resources.REST
  @set_resource 'profiles'
  @params 'age', 'weight', 'height'

class pi.resources.User extends pi.resources.REST
  @set_resource 'users'
  @extend pi.resources.HasOne
  @params 'name','email'
  @has_one 'profile', source: pi.resources.Profile, attribute: true, destroy: true

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