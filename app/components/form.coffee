'use strict'
pi = require '../core'
utils = pi.utils

class pi.Form extends pi.Base
  postinitialize: ->
    super
    @_cache = {}
    @_value = {}
    @former = new pi.Former(@node, serialize: !!@options.serialize, rails: @options.rails)
    
    # handle components updates 
    @on 'update', (e) =>
      return if e.target is @
      @update_value e.target, e.data

    # handle native inputs updates
    @on 'change', (e) =>
      return unless utils.is_input(e.target)
      @update_value e.target.node.name, @former._parse_nod_value(e.target.node)

  value: (val) ->
    if val?
      @former.traverse_nodes @node, (node) => @fill_value node, val
    else
      @_value

  clear: ->
    @_value = {}
    @former.traverse_nodes @node, (node) => @clear_value node, val

  fill_value: (node, val) ->
    if !node._nod && utils.is_input(node)
      @former._fill_nod node, val
    else if (nod = node._nod) instanceof pi.BaseInput
      val = @former._nod_data_value(nod.node.name, val) if nod.node.name?
      return unless val?
      nod.value val

  clear_value: (node) ->
    if !node._nod && utils.is_input(node)
      @former._clear_nod node
    else if (nod = node._nod) instanceof pi.BaseInput
      nod.clear()

  update_value: (name, val) ->
    return unless name
    name = @former.options.name_transform(name) if @former.options.name_transform?
    utils.set_path @_value, name, val
    @trigger 'update', @_value