'use strict'
pi = require '../../core'
require '../rest'
utils = pi.utils

_true = -> true
_false = -> false

# add has_one to resource
# @example
# 
# ```@has_one 'user', source: $r.User, foreign_key: 'resource_id'```

class pi.resources.HasOne
  @extended: (klass) ->
    true

  @has_one: (name, params) ->
    unless params?
      throw Error("Has one require at least 'source' param")

    params.foreign_key ||= "#{@resource_name}_id"

    resource_name = params.source.resource_name
    bind_fun = "bind_#{name}"

    @register_association name

    # add update trigger
    if typeof params.update_if is 'function'
      _update_filter = params.update_if
    else if params.update_if is true
      _update_filter = _true
    else
      _update_filter = _false

    params.source.listen (e) => 
      return unless @all().length
      e = e.data
      if e.type is pi.ResourceEvent.Load
        for el in params.source.all()
          if el[params.foreign_key] and (target = @get(el[params.foreign_key])) and target.association(name)
            target[bind_fun] el
      else
        el = e[resource_name]
        if el[params.foreign_key] and (target = @get(el[params.foreign_key])) and target.association(name)
          if e.type is pi.ResourceEvent.Destroy
            delete @[name]
          else if e.type is pi.ResourceEvent.Create
            target[bind_fun] el, true
          target.trigger_assoc_event(name, e.type, utils.wrap(name, @[name])) if _update_filter(e,el) 

    # bind function
    @::[bind_fun] = (el, silent = false) ->
      return if not el?
      @[name] = el
      if @_persisted and not @[name][params.foreign_key]
        @[name][params.foreign_key] = @id
      @trigger_assoc_event(name, pi.ResourceEvent.Create, utils.wrap(name, @[name])) unless (silent or not _update_filter(null, el))

    # add callbacks

    @after_initialize ->
      if @_persisted and (el = params.source.get_by(utils.wrap(params.foreign_key,@id)))
        @[bind_fun](el, true)

    @after_update (data) ->
      return if data instanceof pi.resources.Base
      if @_persisted and not @[name] and (el = params.source.get_by(utils.wrap(params.foreign_key,@id)))
        @[bind_fun](el, true)
      if data[name]
        if @[name] instanceof pi.resources.Base 
          @[name].set data[name]
        else
          @[bind_fun] params.source.build data[name]


    if params.destroy is true
      @before_destroy ->
        @[name]?.remove()

    # hack attributes
    if params.attribute is true
      _old = @::attributes
      @::attributes = ->
        data = _old.call(@)
        data[name] = @[name].attributes()
        data