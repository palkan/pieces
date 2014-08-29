'use strict'
pi = require '../core'
require './base'
utils = pi.utils

_path_reg = /:(\w+)\b/g

_double_slashes_reg = /\/\//

_tailing_slash_reg = /\/$/


_set_param = (data, from, param) ->
  return unless from?
  if Array.isArray(from)
    for el in from
      do(el) ->
        el_data = {}
        _set_param(el_data, el, param)
        data.push el_data
    data
  else
    if typeof param is 'string'
      data[param] = from[param] if from[param]?
    else if Array.isArray(param)
      for p in param
        _set_param(data,from,p)
    else
      for own key, vals of param
        return unless from[key]?
        if Array.isArray(from[key]) then (data[key]=[]) else (data[key]={})
        _set_param(data[key], from[key], vals)
  data

# REST resource
class pi.resources.REST extends pi.resources.Base
  @_rscope: "/:path"

  # define how to send instance params on create/update requests to server 
  # if true then wrap attributes in resource name: {model: {..attributes...}}
  # otherwise send attributes object 
  wrap_attributes: false

  # define which attributes send to server
  # e.g. params('id','name',{tags: ['name','id']})
  # creates 'attributes' method
  @params: (args...) ->
    args.push('id') if args.indexOf('id')<0 
    @::attributes = ->
      @__attributes__ ||= _set_param({}, @, args)

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
            @constructor._request(spec.path, spec.method, utils.merge(params, id: @id)).then(
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

  @_interpolate_path: (path,params) ->
    path = @_rscope.replace(":path",path).replace(_double_slashes_reg, "/").replace(_tailing_slash_reg,'')
    path_parts = path.split _path_reg
    path = ""
    flag = false
    for part in path_parts
      if flag
        path+=params[part]
      else
        path+=part
      flag = !flag
    path

  @error: (action, message) ->
    pi.event.trigger "net_error", resource: @resources_name, action: action, message: message


  @_request: (path, method, params) ->
    path = @_interpolate_path path, utils.merge(params,{resources: @resources_name, resource: @resource_name})

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
      el

  @build: ->
    el = super
    el._persisted = true if el.id?
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
      @set params, true
      @commit()
      @_persisted = true
      @constructor.add @
      @trigger 'create'
      @

  set: ->
    @__attributes__ = null
    super

  save: ->
    attrs = if @wrap_attributes then @_wrap(@attributes()) else @attributes()
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