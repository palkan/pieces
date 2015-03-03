'use strict'
pi = require '../core'
require './base'
utils = pi.utils
History = require '../core/utils/history'

# The entry point for all actions; 
# controllers, contexts and so on...
# 
# Context = controller + view - isolated module.
# Only one context can be active at a time.

class pi.controllers.Page extends pi.Core
  constructor: ->
    @_contexts = {}
    @context_id = null
    @_history = new History()
  # add context (controller) to page
  # if main is true then the controller will be loaded after initialization 
  add_context: (controller, main) ->
    @_contexts[controller.id] = controller
    @_main_context_id = controller.id if main

  initialize: () ->   
    @switch_context null, @_main_context_id


  wrap_context_data: (context, data) ->
    res = {}
    res.context = context.id if context?
    if context?.data_wrap?
      res.data = {}
      res.data[context.data_wrap] = data
    else
      res.data = data
    res

  # Switch context (controller-view).
  # @params [String] from context id of current context
  # @params [String] to context id of new id
  # @params [*] data additional data to be passed to new context's swithed function

  switch_context: (from,to,data={}, exit = false) ->
    if from and from != @context_id
      utils.warning "trying to switch from non-active context"
      return utils.promise.rejected()

    return if (!to || (@context_id is to))

    if !@_contexts[to]
      utils.warning "undefined context: #{to}"
      return utils.promise.rejected()

    utils.info "context switch: #{from} -> #{to}"
    
    new_context = @_contexts[to]

    promise = 
      if !exit and new_context.preload? and (typeof new_context.preload is 'function')
        new_context.preload()
      else
        utils.promise.resolved()

    promise.then( 
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
      utils.promise.rejected()
  
  dispose: ->
    @context = undefined
    @context_id = undefined
    @_contexts = {}
    @_history.clear()


pi.app.page = new pi.controllers.Page()

pi.Compiler.modifiers.push (str) -> 
  if str[0..1] is '@@'
    str = "@app.page.context." + str[2..]
  str

module.exports = pi.controllers.Page
