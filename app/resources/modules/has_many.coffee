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
        options = {}
        if params.belongs_to is true
          default_scope = {}
          default_scope["#{@constructor.resource_name}_id"] = @id
          unless params.scope?
            options.scope = default_scope
          else
            options.scope = params.scope 
          options.owner = @
          if params.params?
            params.params.push "#{@constructor.resource_name}_id"
        utils.extend options, params
        @["__#{name}__"] = new pi.resources.Association(params.source, options.scope, options)
        @["__#{name}__"].load params.source.where(options.scope) unless options.scope is false
      @["__#{name}__"]

    # add route and handler
    if params.route is true
      @routes member: [{action: "load_#{name}", path: params.path, method: params.method}] 
      @::["on_load_#{name}}"] = (data) ->
        @["#{name}_loaded"] = true
        if data[name]?
          @[name]().load data[name]

    # add callbacks
    @before_initialize (data) ->
      if data[name]
        @id = data.id # because we need when belongs_to is true
        @[name]().load data[name]
        delete data[name]

    @after_initialize ->
      @[name]() # just call association on init to load already created resources

    # hack attributes
    if params.attribute is true
      _old = @::attributes
      @::attributes = ->
        data = _old.call(@)
        data[name] = @[name]().serialize()
        data