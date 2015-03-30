'use strict'
utils = require './base'

# Object utils
class PromiseUtils
  # return data as resolved promise  
  @resolved: (data) ->
    new Promise( (resolve) -> resolve(data))  

  # return data as rejected promise
  @rejected: (error) ->
    new Promise((_,reject) -> reject(error))

  # return data with delay as promise
  @delayed: (time, data, rejected = false) ->
    new Promise(
      (resolve, reject) ->
        utils.after time, ->
          if rejected then reject(data) else resolve(data)
    )

  # if obj is promise then return it; otherwise wrap it in resolved promise
  @as: (obj) ->
    if PromiseUtils.is(obj) then obj else PromiseUtils.resolved(obj)

  # check that given object is a promise  
  @is: (obj) ->
    obj && (typeof obj is 'object' || typeof obj is 'function') && typeof obj.then is 'function'


module.exports = PromiseUtils
