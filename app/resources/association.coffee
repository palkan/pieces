'use strict'
pi = require '../core'
require './base'
require './view'
utils = pi.utils

class pi.resources.Association extends pi.resources.View
  # generate new view for resource
  constructor: (@resources, scope, @options={}) ->
    super
    if options.owner?
      @owner = @options.owner
      @owner_name_id = "#{@owner.constructor.resource_name}_id"

  # create new resource
  build: (data={}, silent = false, add = true) ->
    if @owner?
      unless data[@owner_name_id]?
        data[@owner_name_id] = @owner.id
    unless data instanceof pi.resources.Base
      data = @resources.build data, false
    super data, silent, add

  on_update: (el) ->
    if @options.copy is false
      @trigger 'update', @_wrap(el)
    else
      super

  on_destroy: (el) ->
    if @options.copy is false
      @trigger 'destroy', @_wrap(el)
    else
      super

  on_create: (el) ->
    if (view_item = @get(el.id))
      if @options.copy is false
        @trigger 'create', @_wrap(el)
      else
        view_item.set(el.attributes())
    else
      @build el

  on_load: ->
    if @options.scope
      @load @resources.where(@options.scope)
      @trigger 'load',{}