'use strict'
pi = require '../core'
utils = pi.utils
History = require '../core/utils/history'

class pi.controllers.Context extends pi.Core
  # Creates new Context
  # 
  # Options:
  #  - scope: false | 'one_for_all' | 'all' - defines
  #  whether the context can have subcontext (if not falsey)
  #  and what kind of scoping it provides.
  #  'one_for_all' means that only one subcontext at a time can be loaded,
  #  'all' means that all subcontexts are (un)loaded simultaneously.
  constructor: (@options = {}) ->
    super
    @_contexts = {}
    @context_id = null
    @_history = new History()

  # add sub-context
  add_context: (controller) ->
    @_contexts[controller.id] = controller
    controller.host_context = @

  initialize: () ->   

  @register_callback 'initialize'