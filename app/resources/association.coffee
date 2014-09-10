'use strict'
pi = require '../core'
require './base'
require './view'
utils = pi.utils

class pi.resources.Association extends pi.resources.View
  # generate new view for resource
  constructor: (@resources, scope, @options={}) ->
    super
    @owner = @options.owner
    if options.belongs_to is true
      if options.owner._persisted
        @owner_name_id = @options.key
      else
        @_only_update = true # flag to indicate that association cannot handle create/load events, because it isn't persisted
        @options.owner.one 'create', 
          (=>
            @_only_update = false
            @owner = @options.owner
            @owner_name_id = @options.key
            unless @options._scope is false
              if @options._scope?[@options.key]?
                @options.scope = utils.merge(@options._scope, utils.wrap(@options.key,@owner.id))
              else
                @options.scope = utils.wrap(@options.key,@owner.id)
              @reload()
          )

  clear_all: ->
    @owner["#{@options.name}_loaded"] = false if @options.route
    super

  reload: ->
    @clear_all()
    if @options.scope
      # update view filter
      @_filter = utils.matchers.object_ext(@options.scope)
      # reload associated resources
      @load @options.source.where(@options.scope)

  # create new resource
  build: (data={}, silent = false, params={}) ->
    if @options.belongs_to is true
      unless data[@owner_name_id]?
        data[@owner_name_id] = @owner.id
      unless data instanceof pi.resources.Base
        data = @resources.build data, false
    super data, silent, params

  on_update: (el) ->
    if @get(el.id)
      if @options.copy is false
        @trigger 'update', @_wrap(el)
      else
        super
    else
      @build el

  on_destroy: (el) ->
    if @options.copy is false
      @trigger 'destroy', @_wrap(el)
    else
      super

  on_create: (el) ->
    return if @_only_update
    if (view_item = @get(el.id))
      if @options.copy is false
        @trigger 'create', @_wrap(el)
      else
        view_item.set(el.attributes())
    else
      @build el

  on_load: ->
    return if @_only_update
    if @options.scope
      @load @resources.where(@options.scope)
      @trigger 'load',{}