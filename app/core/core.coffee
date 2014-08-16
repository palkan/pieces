do(context = this) ->

  # shortcuts
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  class pi.Core
    # extend class prototype with mixin methods
    @include: (mixins...) ->
      for mixin in mixins
        utils.extend @::, mixin::, true, ['constructor']
        mixin.included @

    # extend class with mixin class methods
    @extend: (mixins...) ->
      for mixin in mixins
        utils.extend @, mixin, true
        mixin.extended @

    @alias: (from, to) ->
      @::[from] = (args...) ->
        @[to].apply(@,args)
      return

    @class_alias: (from, to) ->
      @[from] = @[to]
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

    # delegate methods to another object or nested object/method (then to is string key)
    delegate_to: (to, methods...) ->
      to = if typeof to is 'string' then @[to] else to
      
      for method in methods
        do (method) => 
          @[method] = (args...) ->
            to[method].apply(to, args)
      return
