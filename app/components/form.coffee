'use strict'
Base = require './base'
Events = require './events'
Validator = require './utils/validator'
utils = require '../core/utils'
Former = require '../core/former/former'
Nod = require('../core/nod').Nod
BaseInput = require './base_input'
Klass = require './utils/klass'

_array_name = (name) ->
  name.indexOf('[]')>-1

class Form extends Base
  postinitialize: ->
    super
    @_cache = {}
    @_value = {}
    @_invalids = []
    @former = new Former(@node, @options)
    
    # set initial value
    @read_values()

    # handle components updates 
    @on Events.InputEvent.Change, (e) =>
      e.cancel()
      if @validate_nod(e.target) 
        @update_value e.target.name(), e.data

    # handle native inputs updates
    @on 'change', (e) =>
      return unless utils.is_input(e.target.node)
      if @validate_nod(e.target)
        @update_value e.target.node.name, @former._parse_nod_value(e.target.node)

    @form = if @node.nodeName is 'FORM' then @ else @find('form')

    if @form?
      @form.on 'submit', (e) =>
        e.cancel()
        @submit()

  submit: ->
    @read_values()
    if @validate() is true
      @trigger Events.FormEvent.Submit, @_value

  value: (val) ->
    if val?
      @_value = {}
      @former.traverse_nodes @node, (node) => @fill_value node, val
      @read_values()
      @
    else
      @_value

  clear: (silent = false)->
    @_value = {}
    @former.traverse_nodes @node, (node) => @clear_value node
    if @former.options.clear_hidden is false
      @read_values()
    @trigger Events.InputEvent.Clear unless silent

  read_values: ->
    _name_values = []
    @former.traverse_nodes @node, 
      (node) =>
        if ((nod = Nod.fetch(node._nod)) instanceof BaseInput) && nod.name()
          @_cache[nod.name()] = nod unless _array_name(name)
          _name_values.push name: nod.name(), value: nod.value()
        else if utils.is_input(node) && node.name
          @_cache[node.name] = Nod.create(node) unless _array_name(node.name)
          _name_values.push name: node.name, value: @former._parse_nod_value(node)
    @_value = @former.process_name_values(_name_values)

  find_by_name: (name) ->
    if @_cache[name]?
      return @_cache[name]

    nod = @find("[name=#{name}]")
    if nod?
      return (@_cache[name] = nod)

  fill_value: (node, val) ->
    if ((nod = Nod.fetch(node._nod)) instanceof BaseInput) && nod.name()
      val = @former._nod_data_value(nod.name(), val)
      return unless val?
      nod.value val
    else if utils.is_input(node)
      @former._fill_nod node, val

  validate: ->
    @former.traverse_nodes @node, (node) => @validate_value node
    if @_invalids.length
      @trigger Events.FormEvent.Invalid, @_invalids
      false
    else
      true

  validate_value: (node) ->
    if (nod = Nod.fetch(node._nod)) instanceof BaseInput
      @validate_nod nod

  validate_nod: (nod) ->
    if (types = nod.data('validates'))
      flag = true
      for type in types.split(" ")
        unless Validator.validate(type, nod, @)
          nod.addClass Klass.INVALID
          flag = false
          break 
        
      if flag
        nod.removeClass Klass.INVALID
        if nod.__invalid__
          @_invalids.splice @_invalids.indexOf(nod.name()), 1
          delete nod.__invalid__
        true
      else
        unless nod.__invalid__?
          @_invalids.push nod.name()
        nod.__invalid__ = true
        false
    else
      true

  clear_value: (node) ->
    if (nod = Nod.fetch(node._nod)) instanceof BaseInput
      nod.clear()
    else if utils.is_input(node)
      @former._clear_nod node

  update_value: (name, val, silent = false) ->
    return unless name
    name = @former.transform_name name
    val = @former.transform_value val

    # cannot proccess array value without context
    return if _array_name(name) is true
    
    utils.obj.set_path @_value, name, val
    @trigger Events.FormEvent.Update, @_value unless silent

module.exports = Form
