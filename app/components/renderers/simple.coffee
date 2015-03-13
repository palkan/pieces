'use strict'
pi = require '../../core'
require './base'
utils = pi.utils

_reg_partials = /\{\>([\s\S]+?)\{\<[\s\S]+?\}/g

_reg_simple = /\{\{([\s\S]+?)\}\}|\{\?([\s\S]+?)\?\}|\{!([\s\S]+?)!\}|$/g

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
    hash = @to_hash(text)
    index = 0
    source = "__p+='"

    text.replace(_reg_simple, (match, escape, conditional, evaluation, offset) =>
      source += @escape(text.slice(index, offset))
      
      source += "'+\n(pi.utils.escapeHTML(__obj.#{escape})||'')+\n'" if escape
      
      # if (interpolate) {
      #   source += "'+\n((__t=(" + interpolate + "))==null?'':__t)+\n'";
      # }
      # if (evaluate) {
      #   source += "';\n" + evaluate + "\n__p+='";
      # }
      index = offset + match.length
      match
    )

    source += "';\n"

    source = """
      var __t,__p='';__obj = __obj || {};
      #{source}
      return __p;
      //# sourceURL=/simpletemplates/source_#{hash}";
      """
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

  render: (data, piecified, host) ->
    if data instanceof pi.Nod
      super
    else
      nod = pi.Nod.create @templater(data)
      @_render nod, data, piecified, host

module.exports = pi.Renderers.Jst
