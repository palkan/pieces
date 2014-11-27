'use strict'
pi = require '../../core'
require '../../components/base/base_input'
require '../../components/events/input_events'
utils = pi.utils

class pi.SearchInput extends pi.TextInput
  postinitialize: ->
    super
    @input.on 'keyup', utils.debounce((@options.debounce || 300),@_query,@)

  _query: ->
    @activate() if !@active
    val = @value()

    utils.debug "query: #{ val }"      

    @trigger pi.Events.Query, val

    @deactivate() if !val

  reset: ->
    @value('')
    @deactivate()
    @trigger pi.Events.Query, ''