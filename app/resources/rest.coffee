'use strict'
Base = require './base'
EventDispatcher = require('../core/events').EventDispatcher
ResourceEvent = require './events'
utils = require '../core/utils'
Net = require '../net'

_path_reg = /:\w+/g

_double_slashes_reg = /\/\//

_tailing_slash_reg = /\/$/


# REST resource
class REST extends Base
  # Routes namespace
  @_rscope: "/:path"

  # Global vars that can be used in route interpolation
  @_globals: {}

  # Defines how to send instance params on create/update requests to server 
  # if true then wrap attributes in resource name: {model: {..attributes...}}
  # otherwise send attributes object 
  wrap_attributes: false

  # Accepts an arbitrary number of other resources which can be created
  # by this resource's actions (i.e. server response can contain other resources as well)
  @can_create = (args...) ->
    @__deps__ = (@__deps__||=[]).concat(args)

  # define which attributes send to server
  # e.g. params('id','name',{tags: ['name','id']})
  # creates 'attributes' method
  @params: (args...) ->
    if not @::hasOwnProperty("__filter_params__")
      @::__filter_params__ = []
      @::__filter_params__.push('id')
    @::__filter_params__ = @::__filter_params__.concat args

  # initialize resource with name
  # and setup default resource paths
  @set_resource: (plural, singular) ->
    super
    @routes 
      collection:
        [
          {action: 'show', path: ":resources/:id", method: "get"},
          {action: 'fetch', path: ":resources", method: "get"}
        ]
      member: 
        [
          {action: 'update', path: ":resources/:id", method: "patch"},
          # we have 'destroy' method to handle unpersisted elements
          {action: '__destroy', path: ":resources/:id", method: "delete"},
          {action: 'create', path: ":resources", method: "post"}
        ]
    @::["destroy_path"] = ":resources/:id"

  # Set globals vars for path interpolation  
  @set_globals: (data) ->
    utils.extend(@_globals, data, true)

  # Generate routes (and methods) for resource
  # 'data' should either or both 'member' and 'collection' fields.
  #
  # @example
  #   Resource.routes 
  #     collection:
  #       [
  #         {action: 'show', path: ":resources/:id", method: "get"},
  #         {action: 'fetch', path: ":resources", method: "get"}
  #       ]
  #       member: 
  #       [
  #         {action: 'update', path: ":resources/:id", method: "patch"},
  #         {action: 'create', path: ":resources", method: "post"}
  #       ]
  @routes: (data) ->
    if data.collection?
      for spec in data.collection
        do (spec) =>
          @[spec.action] = (params={}) ->
            @_request(spec.path, spec.method, params).then( 
              (response) =>
                if @__deps__?
                  dep.from_data(response) for dep in @__deps__
                if @["on_#{spec.action}"]? 
                  @["on_#{spec.action}"](response)
                else
                  @on_all response
            ) 
          @["#{spec.action}_path"] = spec.path
    if data.member?
      for spec in data.member
        do (spec) =>
          @::[spec.action] = (params={}) ->
            @constructor._request(spec.path, spec.method, utils.merge(params, id: @id), @).then(
              (response) =>
                if @constructor.__deps__?
                  dep.from_data(response) for dep in @constructor.__deps__
                if @["on_#{spec.action}"]? 
                  @["on_#{spec.action}"](response)
                else
                  @on_all response
            )
          @::["#{spec.action}_path"] = spec.path            

  # Set common namespace for all action (i.e. '/api/:path', don't forget about slash!)
  @routes_namespace: (scope) ->
    @_rscope = scope

  @_interpolate_path: (path, params, target) ->
    path = @_rscope.replace(":path",path).replace(_double_slashes_reg, "/").replace(_tailing_slash_reg,'')
    
    # check if attributes wrapped
    if @::wrap_attributes and params[@resource_name]? and (typeof params[@resource_name] is 'object')
      vars = utils.extend params[@resource_name], params, false, [@resource_name]
    else
      vars = params

    path.replace(_path_reg, (match) =>
      part = match[1..]
      vars[part] ? target?[part] ? @_globals[part]
    )

  @error: (action, message) ->
    EventDispatcher.Global.trigger "net_error", resource: @resources_name, action: action, message: message

  @_request: (path, method, params, target) ->
    path = @_interpolate_path path, utils.merge(params,{resources: @resources_name, resource: @resource_name}), target

    Net[method].call(null, path, params)
    .catch( (error) =>  
        @error error.message 
        throw error # rethrow it to the top!
    )

  @on_all: (data) ->
    if data[@resources_name]?
      data[@resources_name] = @load(data[@resources_name])
    data

  @on_show: (data) ->
    if data[@resource_name]?
      el = @build data[@resource_name]
      el

  # Find element by id
  @find: (id) ->
    el = @get(id)
    if el?
      utils.promise.resolved(el)
    else
      @show(id: id)

  # Find element by params
  @find_by: (params) -> 
    el = @get_by params
    if el?
      utils.promise.resolved(el)
    else
      @show params

  # Create new element
  @create: (data) ->
    el = @build data
    el.save()

  # Get interpolated path by name
  # or by scheme
  # @example
  #   Resource.path('show', id: 1) #=> '/resources/1'
  #   Resource.path('/:resources/kill/:id', id: 1) #=> '/resources/kill/1'
  @path: (name, params={}, target) ->
    path_scheme = @["#{name}_path"] || @::["#{name}_path"] || name
    @_interpolate_path(path_scheme, params, target)

  destroy: ->
    if @_persisted
      @__destroy()
    else
      utils.promise.resolved(@remove())


  on_destroy: (data) ->
    @constructor.remove @
    data

  @alias 'on___destroy', 'on_destroy'

  on_all: (data) ->
    params = data[@constructor.resource_name]
    if params?
      @set params
      @
  
  on_create: (data) ->
    params = data[@constructor.resource_name]
    if params?
      @set params
      @

  attributes: ->
    if @__attributes__changed__
      if @__filter_params__
        @__attributes__ = utils.extract(@, @__filter_params__)
      else
        @__attributes__ = super
    @__attributes__

  set: ->
    @__attributes__changed__ = true
    super

  save: (params={}) ->
    attrs = @attributes()
    utils.extend attrs, params, true
    attrs = if @wrap_attributes then @_wrap(attrs) else attrs
    if @_persisted
      @update attrs
    else
      @create attrs

  rollback: ->
    for key, param in @changes
      @[key] = @_snapshot[key]
    @changes = {}
    @

  @register_callback 'save'

  path: (name, params) ->
    @constructor.path(name, params, @)

  _wrap: (attributes) ->
    data = {}
    data[@constructor.resource_name] = attributes
    data

module.exports = REST
