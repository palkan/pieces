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
    super

  on_create: (el) ->
    if (view_item = @get(el.id))
      view_item.set(el.attributes())
    else
      @build el