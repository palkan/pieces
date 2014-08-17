pi = require 'core'
require '../base/list'
utils = pi.utils

# [Renderer]
# Setup JST template as renderer for list by name

class pi.List.Renderers.Jst extends pi.List.Renderers.Base
  constructor: (template) ->
    @templater = JST[template]

  render: (data) ->
    nod = pi.Nod.create @templater(data)
    @_render nod, data