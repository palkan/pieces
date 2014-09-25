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
        options = name: name, owner: @
        if params.belongs_to is true
          options.key = params.key || "#{@constructor.resource_name}_id"
          options.copy = false unless params.copy?
          options._scope = params.scope
          default_scope = utils.wrap options.key, @id
          unless params.scope?
            options.scope = if @._persisted then default_scope else false
          else
            options.scope = params.scope 
          if params.params?
            params.params.push "#{@constructor.resource_name}_id"
        utils.extend options, params
        @["__#{name}__"] = new pi.resources.Association(params.source, options.scope, options)
        @["__#{name}__"].load params.source.where(options.scope) unless options.scope is false
      @["__#{name}__"]

    # add route and handler
    if params.route is true
      @routes member: [{action: "load_#{name}", path: params.path, method: params.method}] 
      @::["on_load_#{name}"] = (data) ->
        @["#{name}_loaded"] = true
        if data[name]?
          @[name]().load data[name]

    # add callbacks
    @after_update (data) ->
      return if data instanceof pi.resources.Base
      if data[name]
        @["#{name}_loaded"] = true
        @[name]().load data[name]

    @after_initialize ->
      @[name]() # just call association on init to load already created resources

    if params.destroy is true
      @before_destroy ->
        @[name]().clear_all(true)

    # hack attributes
    if params.attribute is true
      _old = @::attributes
      @::attributes = ->
        data = _old.call(@)
        data[name] = @[name]().serialize()
        data