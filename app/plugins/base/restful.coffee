'use strict'
Base = require '../../components/base'
Plugin = require '../plugin'
utils = require '../../core/utils'
Renderable = require './renderable'
Compiler = require '../../grammar/compiler'
ResourceEvent = require '../../resources/events'
utils = require '../../core/utils'

# Bind resource to component:
#  - on update re-render component
#  - on destroy remove component   
# Requires Renderable and 'rest' option as compilable string (e.g. 'app.some.user' or 'Resource.get(1)')
class Base.Restful extends Plugin
  id: 'restful'
  initialize: (@target) ->
    super
    @_uid = utils.uid('r')
    unless @target.has_renderable
      @target.attach_plugin Renderable

    if(rest = @target.options.rest)?
      
      f = Compiler.str_to_fun(rest)
      promise = f.call(@)
      
      unless promise instanceof Promise
        promise = if promise then utils.promise.resolved(promise) else utils.promise.rejected()

      promise.then(
        (resource) =>
          @bind resource, (@target.children().length is 0)
        () =>
          utils.error "resource not found: #{rest}", @target.options.rest
      )
    @

  bind: (resource, render = false) ->
    if @resource
      @resource.off ResourceEvent.Update, @resource_update()
      @resource.off ResourceEvent.Create, @resource_update()
    @resource = resource
    unless @resource
      @target.render(null)
      return
    @resource.on [ResourceEvent.Update,ResourceEvent.Create], @resource_update()
    @target.render(resource) if render

  resource_update: (e) ->
    utils.debug_verbose 'Restful component event', e
    @on_update e.currentTarget

  @event_handler 'resource_update'

  on_update: (data) ->
    @target.render data

  dispose: ->
    @bind null

module.exports = Base.Restful
