do (context = this) ->
  "use strict"

  # shortcuts
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  _path_reg = /:(\w+)\b/g

  _double_slashes_reg = /\/\//

  _tailing_slash_reg = /\/$/


  # REST resource
  
  class pi.resources.REST extends pi.resources.Base
    @_rscope: "/:path"

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
                    response
              ) 
      if data.member?
        for spec in data.member
          do (spec) =>
            @::[spec.action] = (params={}) ->
              @constructor._request(spec.path, spec.method, utils.merge(params, id: @id)).then(
                (response) =>
                  if @["on_#{spec.action}"]? 
                    @["on_#{spec.action}"](response)
                  else
                    response
              )

    # set common scope for all action (i.e. '/api/:path', don't forget about slash!)
    # you can set event another domain

    @routes_scope: (scope) ->
      @_rscope = scope

    @_interpolate_path: (path,params) ->
      path_parts = path.split _path_reg
      path = ""
      flag = false
      for part in path_parts
        if flag
          path+=params[part]
        else
          path+=part
        flag = !flag
      (@_rscope.replace(":path",path)).replace(_double_slashes_reg, "/").replace(_tailing_slash_reg,'')

    @error: (action, message) ->
      pi.event.trigger "net_error", resource: @resources_name, action: action, message: message


    @_request: (path, method, params) ->
      path = @_interpolate_path path, utils.merge(params,{resources: @resources_name, resource: @resource_name, scope: @_rscope})

      pi.net[method].call(null, path, params)
      .catch( (error) => @error error.message )

    # requests callbacks
    @on_show: (data) ->
      if data[@resource_name]?
        el = @build data[@resource_name], true
        el._persisted = true
        el

    @on_fetch: (data) ->
      if data[@resources_name]?
        @load data[@resources_name]   

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

    on_destroy: (data) ->
      @constructor.remove @id
      data

    on_update: (data) ->
      params = data[@constructor.resource_name]
      if params? and params.id == @id
        @set params

    on_create: (data) ->
      params = data[@constructor.resource_name]
      if params?
        @set params, true
        @_persisted = true
        @constructor.add @
        @trigger 'create'
        @

    save: ->
      if @_persisted
        @update @attributes()
      else
        @create @attributes()

    # attributes - all object own keys not started with "_" (i.e. "id" is a key, "_temp_id" - is not a key)

    attributes: ->
      res = {}
      for own key,val of @ when key[0] != "_"
        res[key] = val
      res