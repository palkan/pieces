'use strict'
pi = require '../core'
utils = pi.utils
History = require '../core/utils/history'

class Context extends pi.Core
  # Creates new Context
  # 
  #  Options:
  #  - strategy: false | 'one_for_all' | 'one_by_one' | 'all_for_one' - defines
  #  whether the context can have subcontext (if not falsey)
  #  and what kind of scoping it provides.
  #  'one_for_all' means that only one subcontext at a time can be loaded;
  #  'all_for_one' means that all subcontexts are (un)loaded simultaneously (no switches);
  #  'one_by_one' means that several contexts can be loaded, but only one 
  #  of them is active. This strategy extends 'one_for_all' with special switch
  #  types ('switch_up' and 'switch_down'). 
  #  When switching up the current context is not unloaded, but deactivated;
  #  Otherwise it's unloaded.
  #  
  #  Example:
  #  
  #  There are 2 contexts: A and B.
  #  Switch up from A to B: A#deactivate -> B#load(data)
  #  Switch down from B to A: B#unload -> A#activate(data)
  constructor: (@options = {}) ->
    super
    if @options.strategy
      @strategy = Strategy.get(@options.strategy)
      @strategy.initialize(@)
    @preinitialize()

  # initialize instance vars here
  preinitialize: ->
    @_contexts = {}

  @register_callback 'postinitialize', as: 'create', only: 'after'

  # add sub-context
  add_context: (context, options={}) ->
    @_contexts[(options.as ? context.id)] = context
    context.host_context = @

  initialize: ->
    @_initialized = true

  @register_callback 'initialize'

  load: ->
    @initialize() unless @_initialized
    utils.promise.as(@strategy?.load(@))

  @register_callback 'load'

  unload: ->
    @strategy?.unload(@)

  @register_callback 'unload'

  activate: ->

  deactivate: ->

  has_context: (id) ->
    !!@_contexts[id]

  dispose: ->
    @_contexts = {}
    @strategy?.dispose(@)


class Strategy
  @storage: {}

  @register: (id, type) ->
    @storage[id] = type

  @get: (id) ->
    @storage[id]

class Strategy.OneForAll
  # Add history to context
  @initialize: (owner) ->
    owner._history = new History()
    utils.extend(owner, @::)

  # Load default subcontext if exists and not loaded yet
  @load: (@context) ->
    return if @context.context or @__loading
    if (id = @context.options.default) and @context.has_context(id)
      @context.__loading_promise = 
        @context.switch_to(id).then(
          ( =>
            @context.context = @context._contexts[id]
            @context.context_id = id
            delete @context.__loading_promise
          ),
          (
            (e) => 
              delete @context.__loading_promise
              utils.error(e)
              throw e
          )
        )

  @unload: (@context) ->
    # we want to ensure that subcontext was loaded if it's loading
    (@context.__loading_promise || utils.promise.resolved()).then(
      =>
        @context.context?.unload()
    )

  # cleanup context state
  @dispose: (@context) ->
    @context._history = new History()
    delete @context.context
    delete @context.context_id
    delete @context.__loading_promise

  # Switch between subcontexts
  # 
  # Switch phases:
  # 1. Preload target context.
  # 2. Unload current context according to strategy.
  # 3. Load target context according to strategy.
  switch_to: (to, params, history = false) ->
    return utils.promise.rejected("Undefined target context: #{to}") if !to || !@_contexts[to]
    # this data is passed to target context
    data = from: @context_id, params: params

    target = @_contexts[to]

    preloader = target.preload?() ? utils.promise.resolved()

    preloader.then(
      =>
        @context?.unload()
        target.load(params)
        @_history.push(to) unless history
        @context = target
        @context_id = to
    )

  switch_back: (data) ->
    to = @_history.prev()
    # handle empty history gracefully
    return utils.promise.resolved() unless to
    @switch_to to, data, true

  switch_forward: (data) ->
    to = @_history.next()
    # handle empty history gracefully
    return utils.promise.resolved() unless to
    @switch_to to, data, true

class Strategy.OneByOne extends Strategy.OneForAll
  # Switch between contexts with direction (up or down)
  # 'to' - can be object (id, up), or just a string (then switch without direction)
  switch_to: (to_data, params, history = false, up = true) ->
    return utils.promise.rejected("Undefined target context: #{to_data}") if !to_data || (typeof to_data is 'string' && !@_contexts[to_data])
    # when switching from history we have to as object
    [to, up] = if typeof to_data is 'object' then [to_data.id, to_data.up] else [to_data, up] 

    # this data is passed to target context
    data = from: @context_id, params: params

    target = @_contexts[to]

    preloader = target.preload?() ? utils.promise.resolved()

    preloader.then(
      =>
        if up 
          @context?.deactivate()
          target.load(params)
        else
          @context?.unload()
          target.activate(params)
        @_history.push(id: to, up: up) unless history
        @context = target
        @context_id = to
    )

  switch_up: (to, data) ->
    @switch_to to, data

  switch_down: (to, data) ->
    @switch_to to, data, false, false

  # we have to override it to make own properties
  switch_forward: Strategy.OneForAll::switch_forward

  switch_back: (data) ->
    to = @_history.prev()
    # handle empty history gracefully
    return utils.promise.resolved() unless to
    # invert up value
    inverted_to = utils.merge(to, up: !to.up)
    @switch_to inverted_to, data, true

class Strategy.AllForOne
  @initialize: (owner) ->
    utils.extend(owner, @::)

  # Load all subcontexts
  @load: (@context) ->
    ctx.load() for own _, ctx of @context._contexts

  # Unload all subcontexts
  @unload: (@context) ->
    ctx.unload() for own _, ctx of @context._contexts

  # cleanup context state
  @dispose: (@context) ->

  # return context by id
  context: (id) ->
    @_contexts[id]

Strategy.register('one_for_all', Strategy.OneForAll)
Strategy.register('one_by_one', Strategy.OneByOne)
Strategy.register('all_for_one', Strategy.AllForOne)

module.exports = (pi.controllers.Context = Context)
