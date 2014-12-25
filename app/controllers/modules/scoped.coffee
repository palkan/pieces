'use strict'
pi = require '../../core'
require '../base'
utils = pi.utils

# Scope determines whether to load query data from server or it can be parsed locally.
# Stores current query params and defines whether query context has been changed.
class Scope
  # Create scope
  # @param [null, Array] whitelist A list of params keys that should be checked to resolve scope fullness
  # @param [null, Array] blacklist A list of params keys that should be filtered. Blacklist works only if whitelist is null.
  # @param [Object] rules Contains custom rules for specific keys
  # 
  constructor: (@whitelist=[], @blacklist=[], @rules={}) ->
    @is_full = false
    @_scope = {}
    @params = {}

  _filter_key: (key) ->
    if @whitelist.length
      return @whitelist.indexOf(key) > -1
    if @blacklist.length
      return @blacklist.indexOf(key) < 0
    return true

  _merge: (key, val) ->
    if val is null and @_scope[key]?
      delete @_scope[key]
      @is_full = false
      return
    if !@is_full
      @_scope[key] = val
    else
      @_scope[key] = @_resolve key, @_scope[key], val
    return

  _resolve: (key, old_val, val) ->
    if !@rules[key]?
      @is_full = false
      val
    else
      _val = @rules[key]?(old_val,val)
      if _val is false
        @is_full = false 
        val
      else
        _val

  set: (params = {}) ->
    (@params[key] = val) for own key, val of params when @_filter_key(key)

    for key, val of @params
      do =>
        if @_scope[key] isnt val
          @_merge(key, val)

  clear: ->
    @params = {}
    @_scope = {}

  to_s: ->
    _ref = []
    _ref.push("#{key}=#{val}") for key, val of @_scope
    _ref.join("&")

  # Set scope.is_full to true (when all elements for the current query were loaded).

  all_loaded: ->
    utils.debug "Scope is full: #{@to_s()}"
    @is_full = true

  # Set scope.is_full to false

  reload: ->
    utils.debug "Scope should be reloaded: #{@to_s()}"
    @is_full = false

class pi.controllers.Scoped
  @included: (klass) ->
    klass::scope_whitelist = []
    klass::scope_blacklist = []
    klass::scope_rules = {}
    true
  
  scope: ->
    @_scope ||= new Scope(@scope_whitelist, @scope_blacklist, @scope_rules)