do (context = this) ->
  "use strict"
  # shortcuts
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  # [Plugin]
  #
  #  Add 'sort(field,order)' method to list

  class pi.Sortable
    constructor: (@list) ->
      @list.sortable = this
      @list.delegate ['sort'], @
      return

    
    # @params [Array,String] fields
    # @params [Boolean] reverse if true then 'asc' else 'desc'
    # @see pi.utils.sort 

    sort: (fields, reverse = false) ->
      if typeof fields is 'object' then utils.sort(@list.items,fields,reverse) else utils.sort_by(@list.items,fields,reverse)
      @list.data_provider @list.items.slice()
      @list.trigger 'sort_update', {fields: fields, reverse: reverse}