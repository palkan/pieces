'use strict'
Core = require '../../core/core'
ResourceEvent = require '../events'
utils = require '../../core/utils'
Association = require '../association'
Base = require '../base'

# Add has_many to resource
# Example
# 
#   @has_many 'users', source: $r.User, [params: ..., scope: ...]
#   # generates method 'load_users' which creates 'users' field as View with provided params 

class HasMany extends Core
  @has_many: (name, params) ->
    unless params?
      throw Error("Has many require at least 'source' param")

    utils.extend params, path: ":resources/:id/#{name}", method: 'get'

    @register_association name

    # setup update trigger
    if typeof params.update_if is 'function'
      _update_filter = params.update_if
    else if params.update_if is true
      _update_filter = utils.truthy

    # add assoc method
    @getter(name, ( ->
      unless @["__#{name}__"]?
        options = name: name, owner: @
        if params.belongs_to is true
          options.key = params.key || "#{@constructor.resource_name}_id"
          options.copy = false unless params.copy?
          options._scope = params.scope
          default_scope = utils.obj.wrap options.key, @id
          unless params.scope?
            options.scope = if @._persisted then default_scope else false
          else
            options.scope = params.scope 
          if params.params?
            params.params.push "#{@constructor.resource_name}_id"
        utils.extend options, params
        @["__#{name}__"] = new Association(params.source, options.scope, options)
        @["__#{name}__"].load params.source.where(options.scope) unless options.scope is false
        @["__#{name}__"].listen(
          (e) =>
            data = e.data[params.source.resources_name] || e.data[params.source.resource_name]
            @trigger_assoc_event(name, e.data.type, data) if _update_filter(e.data.type,data)
        ) if params.update_if
      @["__#{name}__"]
    ))

    # add route and handler
    if params.route is true
      @routes member: utils.obj.wrap("load_#{name}", utils.obj.wrap(params.method, params.path))
      @action_handler(
        "load_#{name}",
        ((data, target) ->
          target["#{name}_loaded"] = true
          if data[name]?
            target[name].load data[name]
          data
        )
      )

    # add callbacks
    @after_update (data) ->
      return if data instanceof Base
      if data[name]
        @["#{name}_loaded"] = true
        @[name].load data[name]

    @after_initialize ->
      @[name] # just call association on init to load already created resources

    if params.destroy is true
      @before_destroy ->
        @[name].clear_all(true)

    # hack attributes
    if params.attribute is true
      @::attributes = utils.func.append(
        @::attributes,
        (data) ->
          data[name] = @[name].serialize()
          data
      )

module.exports = HasMany
