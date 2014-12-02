'use strict'
pi = require '../core'
utils = pi.utils
History = require '../core/utils/history'

pi.controllers = {}

# Context = controller + view - isolated module.
# Only one context can be active at a time.

class pi.controllers.Base extends pi.Core

  # add shortcut for resource
  @has_resource: (resource) ->
    return unless resource.resources_name?
    @::[resource.resources_name] = resource

  id: 'base'

  constructor: (@view, @host_context) ->
    @_initialized = false
    @_contexts = {}
    @context_id = null
    @_history = new History()

  ##
  ## CONTEXT SWITCHING
  ##
  
  # add context (controller) to controller
  # if main is true then the controller will be loaded after initialization 
  add_context: (controller, main) ->
    @_contexts[controller.id] = controller
    controller.host_context = @
    @_main_context_id = controller.id if main

  initialize: () ->   
    @_initialized = true
    if @_main_context_id
      @switch_context(null, @_main_context_id)
    else
      utils.resolved_promise()
      
  # Switch context (controller-view).
  # @params [String] from context id of current context
  # @params [String] to context id of new id
  # @params [*] data additional data to be passed to new context's swithed function

  switch_context: (from,to,data={}, exit = false) ->
    if from and from != @context_id
      utils.warning "trying to switch from non-active context"
      return utils.rejected_promise()

    return utils.rejected_promise() if (!to || (@context_id is to))

    if !@_contexts[to]
      utils.warning "undefined context: #{to}"
      return utils.rejected_promise()

    utils.info "context switch: #{from} -> #{to}"
    
    new_context = @_contexts[to]

    promise = 
      if @context? and exit and (typeof @context.preunload is 'function')
        @context.preunload()
      else
        utils.resolved_promise()

    promise.then(
      =>
        if !exit and new_context.preload? and (typeof new_context.preload is 'function')
          new_context.preload()
        else
          utils.resolved_promise()
    ).then( 
      =>
        if @context?
          if exit then @context.unload() else @context.switched()
    
        data = @wrap_context_data(@context, data)
    
        @_history.push(from) if from? and !exit

        @context = @_contexts[to]
        @context_id = to

        if exit then @context.reload(data) else @context.load data # load new context or return to prev context
    )

  switch_to: (to, data) ->
    @switch_context @context_id, to, data

  switch_back: (data) ->
    if @context?
      @switch_context @context_id, @_history.pop(), data, true
    else
      utils.resolved_promise()

  wrap_context_data: (context, data) ->
    res = {}
    res.context = context.id if context?
    if context?.data_wrap?
      res.data = {}
      res.data[context.data_wrap] = data
    else
      res.data = data
    res

  load: (context_data) ->
    @initialize() unless @_initialized
    @view.loaded context_data.data
    return

  reload: (context_data) ->
    @view.reloaded context_data.data
    return

  switched: ->
    @view.switched()
    return

  unload: ->
    @view.unloaded()
    return

  exit: (data) ->
    @host_context.switch_back data

  switch: (to, data) ->
    @host_context.switch_context @id, to, data

  dispose: ->
    @host_context = undefined
    @context = undefined
    @context_id = undefined
    @view?.dispose()
    @_contexts = {}
    @_history.clear()