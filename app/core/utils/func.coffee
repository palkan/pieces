'use strict'
utils = require './base'

# function modification utils
class Func
  # constant used to break execution of wrapped function
  @BREAK: "__BREAK__"

  # Wrap target function with 2 functions which would be executed 
  # before and after original function respectively;
  # 'before' function receive original arguments and 
  # 'after' function receive original return value as its first arg,
  # original args as second arg (as array) and return value of 'before' function (if any)
  # as third arg. 
  #
  # 'before' function can prevent from calling original function returning `pi.utils.func.BREAK` value.
  #
  #  options:
  #  - this (any) - to be passed as this object to all functions (by default is 'this') 
  #  - break_if_value (bool) - indicates that if 'before' callback returns non-false value this value should be returned
  #  - break_with (any) - value to be return in case of 'before' break
  #
  # Example: Wrap pi.net.request to gather load stats
  #
  # _before = () ->
  #    ts: new Date()
  # _after = (promise, start_data) ->
  #   promise.then(
  #     ->
  #       req_time = new Date() - start_data.ts
  #       utils.info("Request time: #{req_time} ms") 
  #   )
  #
  # pi.net.request = pi.utils.func.wrap(pi.net.request, _before, _after)
  #
  # NOTE: wrapped function always return original return value (though it can be modified within after block)

  @wrap: (target, before, after, options={}) ->
    (args...) ->
      self = options.this || @
      
      if before?
        b = before.apply(self, args)
        return b if b and (options.break_if_value is true)
        return options.break_with if b is Func.BREAK

      res = target.apply(self, args)
      
      if after?
        a = after.call(self, res, args, b)
      res  

  @append: (target, callback, options={}) ->
    Func.wrap target, null, callback, options

  @prepend: (target, callback, options={}) ->
    Func.wrap target, callback, null, options

  # return function to return function) optionally with new 'this'
  @unwrap: (fun, options={}, ths=null) ->
    ->
      if options.debounce?
        return utils.debounce options.debounce, fun, ths||@
      if options.throttle?
        return utils.throttle options.throttle, fun, ths||@
      
      fun.bind(ths||@)

module.exports = Func
