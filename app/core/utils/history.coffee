'use strict'
class History
  # create new history queue with limit
  constructor: (@limit = 10) ->
    @_storage = []
    @_position = -1

  # push element to the top of history
  # if we're in the past, then 'rewrite' future
  # if queue length is greater than limit, drop the past
  push: (item) ->
    if @_position < -1
      @_storage.splice (@_storage.length+@_position+1),(-@_position+1)
      @_position = -1
    @_storage.push item
    # check limit
    if @_storage.length > @limit
      @_storage.shift()

  # get previous element from history
  prev: ->
    return unless (-@_position < @_storage.length)
    @_position -= 1 
    @_storage[@_storage.length+@_position]

  # get next element from history (only if we in the past)
  next: ->
    return if @_position > -2
    @_position += 1
    @_storage[@_storage.length+@_position]

  size: ->
    @_storage.length

  clear: ->
    @_storage.length = 0
    @_position = -1

module.exports = History