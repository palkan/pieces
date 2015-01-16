'use strict'
pi = require '../pi'
require './base'
utils = pi.utils

class utils.arr
  # sort array by many keys provided as hash: {key: order}
  # order is 'asc' or 'desc'
  @sort: (arr, sort_params) ->
    arr.sort utils.curry(utils.keys_compare,[sort_params],utils,true)

  # sort array by key
  @sort_by: (arr, key, order = 'asc') ->
    arr.sort utils.curry(utils.key_compare,[key,order],utils,true)

  @uniq: (arr) ->
    res = []
    for el in arr
      res.push(el) if (el not in res)
    res

  # using Fisher-Yates
  @shuffle: (arr) ->  
    len = arr.length
    res = Array(len)
    for _, i in arr
      j = utils.random(0,i)
      res[i] = res[j] unless i == j
      res[j] = arr[i]
    res

  # return random element (if size is 1) or array of random elements 
  # (without repetitions) from array
  @sample: (arr, size = 1) -> 
    len = arr.length
    if (size is 1)
      return arr[utils.random(len-1)]
    @shuffle(arr)[0..(size-1)]