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
    # extend class with mixin methods
    @include = (mixins...) ->
      for mixin in mixins
        utils.extend @::, mixin::, true
        mixin.included @::

    @class_name: ->
      klass_name @

    @alias: (from, to) ->
      @::[from] = (args...) ->
        @[to].apply(@,args)
      return

    # Returns 'class' name of an object (which equals to constructor.name) 
    class_name: ->
      @constructor.class_name()

    # extend instance with mixin methods
    include: (mixins...) ->
      for mixin in mixins
        utils.extend @, mixin::, true
        mixin.included @

    # delegate methods to another object or nested object/method (then to is string key)
    delegate_to: (to, methods...) ->
      to = if typeof to is 'string' then @[to] else to
      
      for method in methods
        do (method) => 
          @[method] = (args...) ->
            to[method].apply(to, args)
      return
