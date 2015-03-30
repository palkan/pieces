'use strict'
pi = require '../core'
require './base'
utils = pi.utils

_reg_partials = /\{\>\s*([^\}]+?)\s*\}[\s\S]+?\{\<\s*\1\s*\}/g

_reg_simple = /\{\{([\s\S]+?)\}\}|\{\?([\s\S]+?)\?\}|\{\!([\s\S]+?)\!\}|$/g

_escape_rxp = /\\|'|\r|\n|\t|\u2028|\u2029/g

_escapes =
  "'":      "'"
  '\\':     '\\'
  '\r':     'r'
  '\n':     'n'
  '\t':     't'
  '\u2028': 'u2028'
  '\u2029': 'u2029'

# [Renderer]
# Simple template from html with a little bit of logic
class pi.Renderers.Simple extends pi.Renderers.Base
  constructor: (nod) ->
    @create_templater(nod.html())

  create_templater: (text) ->
    source = @_funstr(text, source)
    
    try
      @templater = new Function('__obj', source)
    catch e
      e.source = source
      throw e
    return

  escape: (str) ->
    return str unless str
    str.replace(_escape_rxp, (match) -> '\\'+_escapes[match])

  to_hash: (text) ->
    text.split("").reduce(
      ((a,b) -> 
        a=((a<<5)-a)+b.charCodeAt(0)
        a&a),
      0)

  parse_conditional: (str) ->
    res = ''
    index = 0
    str.replace(/(['"][^'"]*['"])|$/g, (match, literal, offset) =>
      res += str.slice(index, offset).replace(/\b([a-zA-Z][\w\(\)]*)\b/g, '__obj.$&')
      index = offset + match.length
      res += literal if literal
      match
    )
    res


  render: (data, piecified, host) ->
    if data instanceof pi.Nod
      super
    else
      nod = pi.Nod.create pi.utils.squish(@templater(data))
      @_render nod, data, piecified, host

  # Creates function source from template string 
  _funstr: (text) ->
    hash = @to_hash(text)
    index = 0

    source = ''

    text = text.replace(_reg_partials, (partial) =>
      [_, name, content] = partial.match(/^\{\>\s*(\w+)\s*\}([\s\S]*)\{\<\s*\w+\s*\}$/)      
      partial_source = @_funstr(content.trim())

      fun_name = "_#{name}_#{utils.uid('partial')}"

      source+="\nfunction #{fun_name}(__obj, $parent, $i, $key, $val){#{partial_source}};\n"

      """{!
        __ref = __obj.#{name}
        if(Array.isArray(__ref)){
          for(var i=0, len=__ref.length;i<len;i++){
            __p+=#{fun_name}(__ref[i], __obj, i, null, __ref[i]);
          }
        }else if(typeof __ref === 'object' && __ref){
          for(var k in __ref){
            if(!__ref.hasOwnProperty(k)) continue;
            __p+=#{fun_name}(__ref[k], __obj, null, k, __ref[k]);
          }
        }else if(__ref){
          __p+=#{fun_name}(__obj);
        }
      !}
      """
    )

    source += "\n__p+='"

    text.replace(_reg_simple, (match, escape, conditional, evaluation, offset) =>
      source += @escape(text.slice(index, offset))
      
      if escape
        [_, no_escape, prop] = escape.match(/^(\=)?\s*([\s\S]+?)\s*$/)
        # check reserved vars
        prefix = if prop.match(/^\$(i|key|val|parent)/) then '' else '__obj.'
        escape = prefix+prop
        if no_escape
          source += "'+(((__t = #{escape}) == void 0) ? '' : __t)+'"
        else
          source += "'+(((__t = pi.utils.escapeHTML(#{escape})) == void 0) ? '' : __t)+'"
      
      if conditional
        conditional = if conditional.indexOf(":") > 0 then conditional else conditional+' : \'\''
        conditional = utils.squish(conditional)
        source += "'+(((__t = #{@parse_conditional(conditional)}) == void 0) ? '' : __t)+'"

      source +="';\n#{evaluation};\n__p+='" if evaluation

      index = offset + match.length
      match
    )

    source += "';"

    source = """
      var __ref,__t,__p='';__obj = __obj || {};
      #{source}
      return __p;
      //# sourceURL=/simpletemplates/source_#{hash}";\n
      """

module.exports = pi.Renderers.Jst
