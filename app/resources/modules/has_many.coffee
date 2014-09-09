'use strict'
pi = require '../../core'
require '../rest'
utils = pi.utils

# add has_many to resource
# @example
# 
# ```@has_many 'users', source: $r.User, [params: ..., scope: ...]```
# 
# generates method 'load_users' which creates 'users' field as View with provided params 

class pi.resources.HasMany
  @extended: (klass) ->
    true

  @has_many: (name, params) ->
    unless params?
      throw Error("Has many require at least 'source' param")

    utils.extend params, path: ":resources/:id/#{name}", method: 'get'

    # add assoc method
    @::[name] = ->
      unless @["__#{name}__"]?
        if params.belongs_to is true
          default_scope = {}
          default_scope["#{@constructor.resource_name}_id"] = @id
          params.scope||=default_scope
          params.owner = @
          if params.params?
            params.params.push "#{@constructor.resource_name}_id"
        @["__#{name}__"] = new pi.resources.Association(params.source, params.scope, params)
      @["__#{name}__"]

    # add route and handler
    if params.route is true
      @routes member: [{action: "load_#{name}", path: params.path, method: params.method}] 
      @::["on_load_#{name}}"] = (data) ->
        if data[name]?
          @[name]().load data[name]

    # add callback
    @before_initialize (data) ->
      if data[name]
        @id = data.id # because we need when belongs_to is true
        @[name]().load data[name]
        delete data[name]

    # hack attributes
    if params.attribute is true
      _old = @::attributes
      @::attributes = ->
        data = _old.call(@)
        data[name] = @[name]().serialize()
        data