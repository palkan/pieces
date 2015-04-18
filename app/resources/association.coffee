'use strict'
Base = require './base'
View = require './view'
ResourceEvent = require './events'
utils = require '../core/utils'

class Association extends View
  # Generate new view for resource
  # Options:
  #  belongs_to - set to true if this association has owner (then it handle owner creation event)
  #  owner - association owner (only when `belongs_to` is true)
  # 
  # See other options in View
  constructor: (@resources, scope, @options={}) ->
    super
    @_only_update = false
    @owner = @options.owner
    if @options.belongs_to is true
      if @options.owner._persisted
        @owner_name_id = @options.key
      else
        @_only_update = true # flag to indicate that association cannot handle create/load events, because it isn't persisted
        @options.owner.one ResourceEvent.Create, 
          (=>
            @_only_update = false
            @owner = @options.owner
            @owner_name_id = @options.key

            # update temp associated resources
            for el in @__all__
              el.set(utils.obj.wrap(@owner_name_id, @owner.id), true)

            unless @options._scope is false
              if @options._scope?[@options.key]?
                @options.scope = utils.merge(@options._scope, utils.obj.wrap(@options.key,@owner.id))
              else
                @options.scope = utils.obj.wrap(@options.key,@owner.id)
              @reload()
          )
    else
      @_only_update = true unless @options.scope

  clear_all: ->
    @owner["#{@options.name}_loaded"] = false if @options.route
    super

  reload: ->
    @clear_all()
    if @options.scope
      # update view filter
      @_filter = utils.matchers.object_ext(@options.scope)
      # reload associated resources
      @load @resources.where(@options.scope)

  # create new resource
  build: (data={}, silent = false, params={}) ->
    if @options.belongs_to is true
      unless data[@owner_name_id]?
        data[@owner_name_id] = @owner.id
      unless data instanceof Base
        data = @resources.build data, false
    super data, silent, params

  on_update: (el) ->
    if @get(el.id)
      if @options.copy is false
        @trigger ResourceEvent.Update, @_wrap(el)
      else
        super
    else if @_only_update is false
      @build el

  on_destroy: (el) ->
    if @options.copy is false
      @remove el, true, false
      @trigger ResourceEvent.Destroy, @_wrap(el)
    else
      super

  on_create: (el) ->
    if (view_item = (@get(el.id) || @get(el.__tid__)))
      @created(view_item, el.__tid__)
      if @options.copy is false
        @trigger ResourceEvent.Create, @_wrap(el)
      else
        view_item.set(el.attributes())
    else if !@_only_update
      @build el

  on_load: ->
    return if @_only_update
    if @options.scope
      @load @resources.where(@options.scope)
      @trigger ResourceEvent.Load,{}

utils.extend(Base,
  views_cache: {}
  clear_cache: (key) ->
    if key?
      delete @views_cache[key]
      return
    @views_cache = {}

  cache_view: (params, view) ->
    k = @cache_key_from_object(params)
    @views_cache[@cache_id()][k] = view

  cached_view: (params) ->
    k = @cache_key_from_object(params)
    @views_cache[@cache_id()][k]

  # Generate new view for resource
  view: (params, cache = true) ->
    return view if cache && (view = @cached_view(params))
    view = new Association(@, params, scope: params, copy: false)
    view.reload()
    @cache_view(params, view) if cache
    view

  cache_key_from_object: (data) ->
    keys = Object.keys(data).sort()
    parts = [("#{key}_#{data[key]}") for key in keys]
    parts.join(":")

  cache_id: ->
    @_cache_id ||= utils.uid('res')
    @views_cache[@_cache_id]||={}
    @_cache_id
)

module.exports = Association
