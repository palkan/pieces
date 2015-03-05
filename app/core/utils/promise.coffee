'use strict'
utils = require './base'

# Object utils
class utils.promise
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
    if utils.promise.is(obj) then obj else utils.promise.resolved(obj)

  # check that given object is a promise  
  @is: (obj) ->
    obj && (typeof obj is 'object' || typeof obj is 'function') && typeof obj.then is 'function'


module.exports = utils.promise
