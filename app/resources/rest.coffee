'use strict'
pi = require '../core'
require './base'
utils = pi.utils

_path_reg = /:(\w+)\b/g

_double_slashes_reg = /\/\//

_tailing_slash_reg = /\/$/


# REST resource
class pi.resources.REST extends pi.resources.Base
  @_rscope: "/:path"

  # define how to send instance params on create/update requests to server 
  # if true then wrap attributes in resource name: {model: {..attributes...}}
  # otherwise send attributes object 
  wrap_attributes: false

  # params filter array
  __filter_params__: false

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
          {action: 'destroy', path: ":resources/:id", method: "delete"},
          {action: 'create', path: ":resources", method: "post"}
        ]

  @routes: (data) ->
    if data.collection?
      for spec in data.collection
        do (spec) =>
          @[spec.action] = (params={}) ->
            @_request(spec.path, spec.method, params).then( 
              (response) =>
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
                if @["on_#{spec.action}"]? 
                  @["on_#{spec.action}"](response)
                else
                  @on_all response
            )
          @::["#{spec.action}_path"] = spec.path            

  # set common scope for all action (i.e. '/api/:path', don't forget about slash!)
  # you can set event another domain

  @routes_scope: (scope) ->
    @_rscope = scope

  @_interpolate_path: (path,params,target) ->
    path = @_rscope.replace(":path",path).replace(_double_slashes_reg, "/").replace(_tailing_slash_reg,'')
    path_parts = path.split _path_reg
    
    # check if attributes wrapped
    if @::wrap_attributes and params[@resource_name]?
      vars = utils.extend params[@resource_name], params, false, [@resource_name]
    else
      vars = params

    path = ""
    flag = false
    for part in path_parts
      if flag
        val = if vars[part]? then vars[part] else target?[part]
        throw Error("undefined param: #{part}") unless val?
        path+=val
      else
        path+=part
      flag = !flag
    path

  @error: (action, message) ->
    pi.event.trigger "net_error", resource: @resources_name, action: action, message: message


  @_request: (path, method, params, target) ->
    path = @_interpolate_path path, utils.merge(params,{resources: @resources_name, resource: @resource_name}), target

    pi.net[method].call(null, path, params)
    .catch( (error) =>  
        @error error.message 
        throw error # rethrow it to the top!
    )

  @on_all: (data) ->
    if data[@resources_name]?
      data[@resources_name] = @load(data[@resources_name])
    data

  # requests callbacks
  @on_show: (data) ->
    if data[@resource_name]?
      el = @build data[@resource_name], true
      el._persisted = true
      el.commit()
      el

  @build: ->
    el = super
    el

  # find element by id;
  # return Promise
  @find: (id) ->
    el = @get(id)
    if el?
      new Promise(
        (resolve) =>
          resolve el
      )
    else
      @show(id: id)

  @create: (data) ->
    el = @build data
    el.save()

  constructor: (data) ->
    super
    @_snapshot = data

  on_destroy: (data) ->
    @constructor.remove @
    data

  on_all: (data) ->
    params = data[@constructor.resource_name]
    if params? and params.id == @id
      @set params
      @commit()
      @
  
  on_create: (data) ->
    params = data[@constructor.resource_name]
    if params?
      @_persisted = true
      @set params, true
      @commit()
      @constructor.add @
      @trigger 'create'
      @

  attributes: ->
    if @__attributes__changed__
      if @__filter_params__
        @__attributes__ = utils.extract({}, @, @__filter_params__)
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

  commit: ->
    for key, param in @_changes
      @_snapshot[key] = param.val
    @_changes = {}
    @_snapshot

  rollback: ->
    for key, param in @_changes
      @[key] = @_snapshot[key]
    return

  @register_callback 'save'

  _wrap: (attributes) ->
    data = {}
    data[@constructor.resource_name] = attributes
    data