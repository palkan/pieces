'use strict'
pi = require '../../core'
require '../../components/base/base_input'
require '../../components/events/input_events'
utils = pi.utils

class pi.TextArea extends pi.TextInput
  postinitialize: ->
    @input = if @node.nodeName is 'TEXTAREA' then @ else @find('textarea')
    super