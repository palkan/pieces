'use strict'
utils = require '../../core/utils'

# Class helps to infere component class from Nod
class Guesser
  @klasses: []
  @klass_reg: null
  @klass_to_component: {}

  @tag_to_component: {}

  @specials: {} 

  @compile_klass_reg: ->
    unless @klasses.length
      @klass_reg = null
    else
      @klass_reg = new RegExp("("+@klasses.map((klass) -> "(\\b#{utils.escapeRegexp(klass)}\\b)").join("|")+")","g")

  @rules_for: (component_name, klasses=[], tags=[], fun) ->
    if klasses.length
      for klass in klasses
        @klass_to_component[klass] = component_name
        @klasses.push klass
      @compile_klass_reg()

    if tags.length
      for tag in tags
        (@tag_to_component[tag]||=[]).push component_name

    if typeof fun is 'function'
      @specials[component_name] = fun

  @find: (nod) ->
    matches=[]
    if @klass_reg && (_match = nod.node.className.match(@klass_reg))
      matches = utils.arr.uniq _match
      if matches.length == 1
        return @klass_to_component[matches[0]]

    matches = matches.map((klass) => @klass_to_component[klass])

    tag = nod.node.nodeName.toLowerCase()
    tag+="[#{nod.node.type}]" if tag is 'input'
    
    if @tag_to_component[tag]?
      tmatches = []
      
      if matches.length
        for el in @tag_to_component[tag]
          tmatches.push(el) if (el in matches)
      else
        tmatches = @tag_to_component[tag] 
      
      tmatches = utils.arr.uniq tmatches
    
      if tmatches.length == 1
        return tmatches[0]
      else
        matches = tmatches

    if matches.length
      for m in matches
        if @specials[m]? and @specials[m].call(null,nod)
          return m
      return matches[matches.length-1]
    else
      for own match, resolver of @specials
        if resolver.call(null,nod)
          return match

    return 'base'

module.exports = Guesser
