'use strict'
utils = require './base'

# Object utils
class utils.obj
  # return property by path-like name
  # get_path(obj,'a.b.c') = obj.a.b.c
  @get_path: (obj, path) ->
    parts = path.split "."
    res = obj     
    
    while(parts.length)
      key = parts.shift()
      if res[key]?
        res = res[key]
      else
        return
    res


  # set proprty on path
  @set_path: (obj, path, val) ->
    parts = path.split "."
    res = obj     
    
    while(parts.length>1)
      key = parts.shift()
      unless res[key]?
        res[key] = {}
      res = res[key]
    res[parts[0]] = val

  # convert path parts to camelCase and then get_path
  @get_class_path: (pckg, path) ->
    path = path.split('.').map((p) => utils.camelCase(p)).join('.')
    @get_path pckg, path

  # convert path parts to camelCase and then set_path
  @set_class_path: (pckg, path, val) ->
    path = path.split('.').map((p) => utils.camelCase(p)).join('.')
    @set_path pckg, path, val

  # generate new object containing as key provided object
  @wrap: (key, obj) ->
    data = {}
    data[key] = obj
    data

  # convert array to object: [a, 1, b, 2] -> {a: 1, b: 2}
  @from_arr: (arr) ->
    data = {}
    for _,i in arr by 2
      data[arr[i]] = arr[i+1]
    data

module.exports = utils.obj
