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


  # Switch context (controller-view).
  # @params [String] from context id of current context
  # @params [String] to context id of new id
  # @params [*] data additional data to be passed to new context's swithed function

  switch_context: (from,to,data, history = false) ->
    if from and from != @context_id
      utils.warning "trying to switch from non-active context"
      return

    return if (!to || (@context_id is to))

    if !@_contexts[to]
      utils.warning "undefined context: #{to}"
      return 

    utils.info "context switch: #{from} -> #{to}"
  
    @context.unload() if @context? # unload current context

    @_history.push(from) if from? and !history

    @context = @_contexts[to]
    @context_id = to

    @context.load data # load new context
    return true

  switch_to: (to, data) ->
    @switch_context @context_id, to, data

  switch_back: (data) ->
    if @context?
      @switch_context @context_id, @_history.pop(), data, history
  
  dispose: ->
    @context = null
    @context_id = null
    @_contexts = {}
    @_history.clear()

pi.app.page = new pi.controllers.Page()

# override str_to_fun to handle page calls
_orig = pi.str_to_fun

pi.str_to_fun = (callstr, host) ->
  if callstr[0..1] is '@@'
    callstr = "@app.page.context." + callstr[2..] 
  _orig callstr, host  
