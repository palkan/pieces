'use strict'
pi = require 'pi.components'
TestHelpers = require '../helpers'
pi.log_level = "debug"

class pi.TestComponent extends pi.Base
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
module.exports = TestHelpers