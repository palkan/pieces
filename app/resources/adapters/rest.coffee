'use strict'
Core = require '../../core/core'
utils = require '../../core/utils'
Net = require '../../net'
Base = require '../base'
AbstractStorage = require './abstract'

_path_reg = /:\w+/g

_double_slashes_reg = /\/\//

_tailing_slash_reg = /\/$/

# REST storage
class REST extends AbstractStorage
  # Set globals vars for path interpolation  
  @globals: (data) ->
    utils.extend(@_globals, data, true)
  
  # Global vars that can be used in route interpolation
  @_globals: {}

  # Routes namespace
  _namespace: "/:path"

  # Defines how to send instance params on create/update requests to server 
  # if true then wrap attributes in resource name: {model: {..attributes...}}
  # otherwise send attributes object 
  wrap_attributes: false

  constructor: (@resource, options={}) ->
    @resource_name = @resource.resource_name
    @resources_name = @resource.resources_name
    @wrap_attributes = options.wrap_attributes if options.wrap_attributes?
    @routes( 
      collection:
        find: ":resources/:id"
        fetch: ":resources/"
      member:
        update: { patch: ":resources/:id" }
        create: { post: ":resources/" } 
        destroy: { "delete": ":resources/:id"},
      false
    )

    # delegate API to resource
    
    @resource.delegate_to @,
      'namespace',
      'routes',
      'draw_routes',
      'can_create',
      'action_handler',
      'path'

    # Add path method for resource instance
    @resource::path = (name, params) -> @constructor.path(name, params, @)

  # Generate routes and method for storage.
  # If delegate is true then add methods to resource.
  #
  # @example
  #   @routes 
  #       {
  #         collection: {
  #          find: ":resources/:id",
  #          fetch: ":resources/"
  #         },
  #         member: {
  #          update: { patch: ":resources/:id" },
  #          create: { post: ":resources/" } 
  #         }
  #        }
  routes: (data, delegate = true) ->
    @draw_routes data.collection, delegate
    @draw_routes data.member, delegate, true

  # Draw routes for either collection or member (but not both)
  # @example Routes for collection
  #   @draw_routes 
  #         { 
  #          find: ":resources/:id",
  #          fetch: ":resources/"
  #         }
  draw_routes: (data = {}, delegate = true, member = false) ->
    for own action, val of data
      do (action, val) =>
        if typeof val is 'string'
          path = val
          method = 'get'
        else
          method = Object.keys(val)[0]
          path = val[method]
      
        # cleanup trailing slash
        path = path.replace(_tailing_slash_reg, '')

        # store action path
        @["#{action}_path"] = path

        if member
          @[action] = (el, params) -> @request(action, path, params, method, el)
          
          @resource::[action] = (
            (params) -> @constructor.storage[action](@, params)
          ) if delegate
        else
          @[action] = (params) ->
            @request(action, path, params, method)

          @resource[action] = (
            (params) -> @storage[action](params)
          ) if delegate
    return

  # Set common namespace for all action (i.e. '/api/:path', don't forget about slash!)
  namespace: (scope) ->
    @_namespace = scope

  # Accepts an arbitrary number of other resources which can be created
  # by this resource's actions (i.e. server response can contain other resources as well)
  can_create: (args...) ->
    @__deps__ = (@__deps__||=[]).concat(args)

  # Add custom action handler to storge
  action_handler: (action, handler) ->
    @["on_#{action}"] = handler

  interpolate_path: (path, params, target) ->
    path = @_namespace.replace(":path",path).replace(_double_slashes_reg, "/")
    
    vars = utils.merge(params, resources: @resources_name, resource: @resource_name)

    path.replace(_path_reg, (match) =>
      part = match[1..]
      vars[part] ? target?[part] ? @constructor._globals[part]
    )

  # Get interpolated path by name
  # or by scheme
  # @example
  #   Resource.path('show', id: 1) #=> '/resources/1'
  #   Resource.path('/:resources/kill/:id', id: 1) #=> '/resources/kill/1'
  path: (name, params = {}, target = null) ->
    path_scheme = @["#{name}_path"] || name
    @interpolate_path(path_scheme, params, target)

  request: (action, path, params = {}, method = 'get', target = null) ->
    params = {id: params} if params and typeof params isnt 'object'
    path = @interpolate_path path, params, target

    # wrap params if it's a member action
    params = utils.obj.wrap(@resource_name, params) if target? && (@wrap_attributes is true)

    Net[method].call(null, path, params).then(
      (response) => @handle_repsonse(response, action, target)
    )

  handle_repsonse: (response, action, target) ->
    @handle_deps(response) if @__deps__?
    @["on_#{action}"]?(response, target) ? @on_all(response, target)

  handle_deps: (response) ->
    dep.from_data(response) for dep in @__deps__

  on_all: (data, target) ->
    @resource.from_data(data)

  on_find: (data) ->
    data = @on_all(data)
    data[@resource_name]

  on_destroy: (data, target) ->
    @resource.remove target
    data

module.exports = REST
