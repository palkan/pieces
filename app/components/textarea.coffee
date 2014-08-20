'use strict'
pi = require '../core'
require './base/textinput'
utils = pi.utils

class pi.TextArea extends pi.TextInput
  postinitialize: ->
    @input = if @node.nodeName is 'TEXTAREA' then @ else @find('textarea')
    super

pi.Guesser.rules_for 'text_area', ['pi-textarea'], ['textarea']