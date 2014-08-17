class History
  constructor: ->
    @_storage = []
    @_position = 0

  push: (item) ->
    if @_position < 0
      @_storage.splice (@_storage.length+@_position-1),(-@_position)
      @_position = 0
    @_storage.push item

  pop: ->
    @_position -= 1 
    @_storage[@_storage.length+@_position]

  size: ->
    @_storage.length

  clear: ->
    @_storage.length = 0
    @_position = 0

module.exports = History