'use strict'

class pi.components.TestComponent extends pi.components.Base
  @after_initialize () -> @id = @options.id
  @before_create () -> @on 'click', => @value_trigger(13)

  initialize: ->
    @addClass 'test'
    super

  name: (val) ->
    if val?
      @options.name = val
    else
      @options.name || 'test'

  value_trigger: (val)->
    @trigger "value", val

pi.Guesser.rules_for 'test_component', ['test']
module.exports = pi.components.TestComponent