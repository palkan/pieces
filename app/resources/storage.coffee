'use strict'
Core = require '../core/core'
utils = require '../core/utils'
Base = require './base'

class Storage extends Core
  @included: (base) ->
    base.extend @
    base.register_callback 'save'

  @set_storage: (klass, options) ->
    @storage = new klass(@, options)

  # Find element by id
  @find: (id, force = false) ->
    el = @get(id)
    if !force && el?
      utils.promise.resolved(el)
    else
      utils.promise.as(@storage.find(id))

  # Find element by params
  @find_by: (params, force = false) ->
    el = @get_by(params)
    if !force && el?
      utils.promise.resolved(el)
    else
      utils.promise.as(@storage.find_by(params))

  # Load elements by params
  @fetch: (params = {}) ->
    utils.promise.as(@storage.fetch(params))

  # Create new element
  @create: (data) ->
    el = @build data
    el.save()

  # Destroy element
  destroy: (params = {}) ->
    if @_persisted
      utils.promise.as(@constructor.storage.destroy(@, params))
    else
      utils.promise.resolved(@remove())

  # Save element (create or update)
  save: (params = {}) ->
    attrs = @attributes()
    utils.extend attrs, params, true
    if @_persisted
      utils.promise.as(@constructor.storage.update(@, attrs))
    else
      utils.promise.as(@constructor.storage.create(@, attrs))

module.exports = Storage
