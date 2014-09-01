'use strict'
pi = require '../../core'
require './base'
utils = pi.utils

# [Renderer]
# Setup JST template as renderer for list by name

class pi.Renderers.Jst extends pi.Renderers.Base
  constructor: (template) ->
    @templater = JST[template]

  render: (data, piecified) ->
    if data instanceof pi.Nod
      super
    else
      nod = pi.Nod.create @templater(data)
      @_render nod, data, piecified