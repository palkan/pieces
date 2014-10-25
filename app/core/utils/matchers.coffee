'use strict'
pi = require '../pi'
require './base'

utils = pi.utils

_operands = 
  "?":(values) ->
        (value) ->
          value in values
  "?&":(values) ->
        (value) ->
          for v in values
            return false unless (v in value)
          return true
  ">": (val) ->
        (value) ->
          value >= val
  "<": (val) ->
        (value) ->
          value <= val
  "~": (val) ->
        if typeof val is 'string'
          val = new RegExp(utils.escapeRegexp(val))
        (value) ->
          val.test value


_key_operand = /^([\w\d_]+)(\?&|>|<|~|\?)$/

# Filter functions generators
class pi.utils.matchers
  # object matcher
  # if 'all' is true then matching objects must include passed object
  # @example matchers.object(type: 1, kind: 2) returns 'true' on {type: 1, kind:2, ...}
  # otherwise there should be non-empty intersection
  # @example matchers.object({type: 1, kind: 2}, false) returns 'true' on both {type: 1} and  {kind:2}
  @object: (obj, all = true) ->
    for key,val of obj
      do (key,val) =>
        if not val?
          obj[key] = (value) ->
            !value
        else if typeof val is "object"
          obj[key] = @object val, all
        else if !(typeof val is 'function')
          obj[key] = (value) ->
            val == value

    (item) ->
      return false unless item?
      _any = false
      for key,matcher of obj
        if matcher(item[key])
          _any = true
          return _any unless all
        else
          return false if all
      return _any

  # given Nod object returns true if nod contains string as textContent
  # string can be regexp
  # also it's possible to provide selectors: ".a,.b:smth" matches nods which have substr 'smth' in '.a' node or '.b' node 
  @nod: (string) ->
    string = utils.escapeRegexp(string)
    if string.indexOf(":") > 0
      [selectors, query] = string.split ":"
      regexp = new RegExp(query,'i')
      selectors = selectors.split ','
      (item) ->
        for selector in selectors
          return true if !!item.find(selector)?.text().match(regexp)
        return false
    else
      regexp = new RegExp(string,'i')
      (item) ->
        !!item.text().match(regexp)

  # Extended object matcher works support some special filter functions.
  #  - 'any' filter: filter({key+"?": [val1, val2]}) # true if item[key] = val1 or item[key] = val2
  #  - 'contains' filter (for array values): filter({key+"?&":[val1,val2]})  
  #  - 'greater/less' filters: filter({key+">":val})  
  #  - 'match' filter (RegExp): filter({key+"~":val}) where val is RegExp
  @object_ext: (obj, all = true) ->
    matchers = {}
    for own key, val of obj
      if val? and (typeof val is 'object' and !(Array.isArray(val)))
        matchers[key] = @object_ext val, all
      else
        if (matches = key.match(_key_operand))
          matchers[matches[1]] = _operands[matches[2]] val
        else
          matchers[key] = val
    @object matchers, all