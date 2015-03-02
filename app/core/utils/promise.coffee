'use strict'
utils = require './base'

# Object utils
class utils.promise
  @as_promise: (fun, resolved = true) ->
    new Promise( (resolve, reject) ->
      if resolved
        resolve(fun.call(null))
      else
        reject(fun.call(null))
      )

  @resolved_promise: (data) ->
    new Promise((resolve) -> resolve(data))

  @rejected_promise: (error) ->
    new Promise((_,reject) -> reject(error))

module.exports = utils.promise
