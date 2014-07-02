do (context = this) ->
  "use strict"
  # shortcuts
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  # [Plugin]
  #
  # Add 'filter' method to list
  # Filter items detaching (not hiding!) DOM elements.
  # 
  # Filter works only with item object and support some special filter functions.
  # 
  #   - simple filter (exact match): filter({key1: val, key2: val2})
  #   - 'any' filter: filter({key+"?": [val1, val2]}) # true if item[key] = val1 or item[key] = val2
  #   - 'contains' filter (for array values): filter({key+"?&":[val1,val2]})  
  #   - 'greater/less' filters (for array values): filter({key+">":val})  
  
  _operands = 
    "?":  (values) ->
            (value) ->
                value in values
    "?&": (values) ->
            (value) ->
              for v in values
                return false unless (v in value)
              return true

    ">":  (val) ->
            (value) ->
              value >= val

    "<":  (val) ->
            (value) ->
              value <= val

  _key_operand = /^([\w\d_]+)(\?&|>|<|\?)$/

  class pi.Filterable
    constructor: (@list) ->
      @list.filterable = this
      @list.delegate ['filter'], @
      @list.filtered = false
      return

    _matcher: (params) ->
      obj = {}
      for own key, val of params
        if (matches = key.match(_key_operand))
          obj[matches[1]] = _operands[matches[2]] val
        else
          obj[key] = val
      pi.List.object_matcher obj

    _is_continuation: (params) ->
      for own key,val of @_prevf
        if params[key] != val
          return false
      return true

    _start_filter: () ->
      return if @filtered
      @filtered = true
      @list.addClass 'is-filtered'
      @_all_items = utils.clone(@list.items)
      @_prevf = {}
      @list.trigger 'filter_start'

    _stop_filter: () ->
      return unless @filtered
      @filtered = false
      @list.removeClass 'is-filtered'
      @list.data_provider @_all_items
      @_all_items = null
      @list.trigger 'filter_stop'


    # Filter list items.
    # @param [Object] params 

    filter: (params) ->
      unless params?
        return @_stop_filter()

      @_start_filter() unless @filtered

      scope = if @_is_continuation(params) then @list.items.slice() else utils.clone(@_all_items)

      @_prevf = params

      matcher = @_matcher params

      _buffer = (item for item in scope when matcher(item))
      @list.data_provider _buffer

      @list.trigger 'filter_update'