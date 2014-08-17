pi = require 'core'
require './base/textinput'
utils = pi.utils

class pi.SearchInput extends pi.TextInput
  postinitialize: ->
    super
    @input.on 'keyup', debounce(300,@_query,@)

  _query: ->
    @activate() if !@active
    val = @value()

    utils.debug "query: #{ val }"      

    @trigger 'query', val

    @deactivate() if !val

  reset: ->
    @value('')
    @deactivate()
    @trigger 'query', ''

pi.Guesser.rules_for 'search_input', ['pi-search-field']