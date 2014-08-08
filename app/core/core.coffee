do(context = this) ->

  # shortcuts
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  if Function::name? 
    klass_name = (fun) ->
      fun.name
  else
    klass_name = ->
      _regex = /function (.{1,})\(/
      results = _regex.exec fun.toString()
      results[1]

  class pi.Core
    # extend class prototype with mixin methods
    @include: (mixins...) ->
      for mixin in mixins
        utils.extend @::, mixin::, true, ['constructor']
        mixin.included @

    @class_name: ->
      klass_name @

    @alias: (from, to) ->
      @::[from] = (args...) ->
        @[to].apply(@,args)
      return

    # register before and after callbacks for method
    @register_callback: (method, options={}) ->
      callback_name = options.as || method
      for _when in ["before","after"]
        do(_when) =>
          @["#{_when}_#{callback_name}"] = (callback) ->
            (@["_#{_when}_#{callback_name}"]||=[]).push callback
      _orig = @::[method]
      @::[method] = (args...) ->
        @run_callbacks "before_#{callback_name}"
        res = _orig.apply(@,args)
        @run_callbacks "after_#{callback_name}"
        res 

    run_callbacks: (type) ->
      for callback in (@constructor["_#{type}"]||[])
        callback.call(@)

    # Returns 'class' name of an object (which equals to constructor.name) 
    class_name: ->
      @constructor.class_name()

    # delegate methods to another object or nested object/method (then to is string key)
    delegate_to: (to, methods...) ->
      to = if typeof to is 'string' then @[to] else to
      
      for method in methods
        do (method) => 
          @[method] = (args...) ->
            to[method].apply(to, args)
      return
