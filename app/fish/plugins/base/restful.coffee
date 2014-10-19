'use strict'
pi = require '../../../core'
require '../../../plugins/plugin'
require '../../../components/base/base'
utils = pi.utils

_finder_rxp = /^(\w+)\.find\((\d+)\)$/
_app_rxp = /^app\.([\.\w]+)$/


# [Plugin]
# Bind resource to component:
#  - on update re-render component
#  - on destroy remove component   
#  
# Requires Renderable and 'rest' option as 'app.path.to.some.resource' or 'Resource.find(id)'
class pi.Base.Restful extends pi.Plugin
  id: 'restful'
  initialize: (@target) ->
    super
    unless @target.has_renderable
      @target.attach_plugin pi.Base.Renderable

    if(rest = @target.options.rest)?
      promise = if (matches = rest.match(_app_rxp))
                  new Promise( 
                    (resolve, reject) -> 
                      res = utils.get_path(pi.app, matches[1])
                      if res
                        resolve res
                      else
                        reject res
                    )
                else if(matches = rest.match(_finder_rxp))
                  resources = utils.get_path($r, matches[1])
                  if resources?
                    resources.find(matches[2]|0)
                  else
                    utils.rejected_promise()
      promise.then(
        (resource) =>
          @bind resource, !@target.firstChild
        () =>
          utils.error "resource not found: #{rest}", @target.options.rest
      )
    @

  bind: (resource, render = false) ->
    if @resource
      @resource.off pi.ResourceEvent.Update, @resource_update()
      @resource.off pi.ResourceEvent.Create, @resource_update()
    @resource = resource
    unless @resource
      @target.render(null)
      return
    @resource.on [pi.ResourceEvent.Update,pi.ResourceEvent.Create], @resource_update()
    @target.render(resource) if render

  resource_update: () ->
    @_resource_update ||= (e) =>
      utils.debug 'Restful component event'
      @on_update e.currentTarget

  on_update: (data) ->
    @target.render data

  dispose: ->
    @bind null