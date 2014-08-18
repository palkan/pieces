'use strict'
pi = require '../core'
require './base/textinput'
utils = pi.utils

class pi.TextArea extends pi.TextInput
  initialize: ->
    @input = if @node.nodeName is 'TEXTAREA' then @ else @find('textarea')
    @editable = true
    @make_readonly() if (@options.readonly || @hasClass('is-readonly'))
    @enable_autosize() if @options.autosize is true
    pi.Base::initialize.apply(this)

  autosizer: ->
    @_autosizer ||= =>
      @input.height @input.node.scrollHeight

  enable_autosize: ->
    unless @_autosizing
      @input.on 'change', @autosizer()
      @_autosizing = true
      @autosizer()()
    @

  disable_autosize: ->
    if @_autosizing
      @input.style 'height', null
      @input.off 'change', @autosizer()
      @_autosizing = false
    @

pi.Guesser.rules_for 'text_area', ['pi-textarea'], ['textarea']