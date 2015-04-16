'use strict'
utils = require './utils'

class Core
  @getset: (name, getter, setter, klass = false) ->
    target = if klass then @ else @::
    prop = {}
    prop.get = getter if getter?
    prop.set = setter if setter?
    Object.defineProperties(
      target,
      utils.obj.wrap(
        name,
        prop
      )
    )

  @getter: (name, fun, klass) -> @getset(name, fun, null, klass)
  @setter: (name, fun, klass) -> @getset(name, null, fun, klass)

  # extend class prototype with mixin methods
  @include: (mixins...) ->
    for mixin in mixins
      utils.extend @::, mixin::, true, ['constructor']
      mixin.included @

  # extend class with mixin class methods
  @extend: (mixins...) ->
    for mixin in mixins
      utils.extend @, mixin, true, ['__super__']
      mixin.extended @

  @alias: (from, to) ->
    @::[from] = (args...) ->
      @[to].apply(@,args)
    return

  @class_alias: (from, to) ->
    @[from] = @[to]
    return

  @included: utils.truthy

  @extended: utils.truthy

  @mixedin: utils.truthy

  # register before and after callbacks for method
  @register_callback: (method, options={}) ->
    callback_name = options.as || method
    types = options.only || ["before", "after"]
    types = utils.to_a(types)
    for _when in types
      do(_when) =>
        @["#{_when}_#{callback_name}"] = (callback) ->
          if @::["_#{_when}_#{callback_name}"] and not @::hasOwnProperty("_#{_when}_#{callback_name}")
            @::["_#{_when}_#{callback_name}"] = @::["_#{_when}_#{callback_name}"].slice()
          (@::["_#{_when}_#{callback_name}"]||=[]).push callback
    
    # create callbacked version of a function  
    @::["__#{method}"] = (args...) ->
      @run_callbacks "before_#{callback_name}", args
      res = @constructor::[method].apply(@,args)
      @run_callbacks "after_#{callback_name}", args
      res 

    (@callbacked||=[]).push method

  # Search ancestors for module.
  # 
  # Example
  #   class User
  #   class User.WithPermissions
  #     admin: -> false
  #   
  #   class Admin extends User
  #   class Admin.WithPermissions
  #     admin: -> true
  #  
  #   class Guest extends User
  # 
  #   And we have @user object which can be any of the above
  #   and we want to mixin 'with_permissions' module to it.
  #   
  #   @user.mixin 'with_persmissions' 
  #   
  #   # if @user is a User
  #   @user.admin() # => false
  #   
  #   # if @user is an Admin
  #   @user.admin() # => true
  #   
  #   # if @user is a Guest
  #   @user.admin() # => false
  @lookup_module: (name) -> 
    name = utils.camelCase name
    klass = @
    while(klass?)
      if klass[name]?
        return klass[name]
      klass = klass.__super__?.constructor
    utils.debug "module not found: #{name}"
    return null

  # extend instance with mixins
  mixin: (mixins...) ->
    for mixin in mixins
      if typeof mixin is 'string' 
        mixin = @constructor.lookup_module(mixin)
      continue unless mixin
      utils.extend @, mixin::, true, ['constructor']
      mixin.mixedin @

  # Event handler generator  
  _before = (name) ->
    if @["__h__#{name}"]?
      return @["__h__#{name}"]

  _after = (name, res) ->
    @["__h__#{name}"] = res

  @event_handler: (name, options={}) ->
    return utils.error("undefined handler", @, name) unless typeof @::[name] is 'function'
    @::[name] = utils.func.unwrap(@::[name], options)
    @::[name] = utils.func.wrap(@::[name], utils.curry(_before, name), utils.curry(_after, name), break_if_value: true)

  constructor: ->
    # apply callbacks to methods
    for method in (@constructor.callbacked||[])
      do(method) =>
        @[method] = @["__#{method}"]

  run_callbacks: (type,args) ->
    for callback in (@["_#{type}"]||[])
      callback.apply(@,args)

  # delegate methods to another object or nested object/method (then to is string key)
  delegate_to: (to, methods...) ->
    to = if typeof to is 'string' then @[to] else to
    
    for method in methods
      do (method) => 
        @[method] = (args...) ->
          to[method].apply(to, args)
    return

module.exports = Core
