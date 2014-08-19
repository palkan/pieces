'use strict'
pi = require '../../core'
require './base'
utils = pi.utils
# [Renderer]
# Mustache based renderer

class pi.Renderers.Mustache extends pi.Renderers.Base
  constructor: (template) ->
    throw Error('Mustache not found') unless window.Mustache?

    tpl_nod = $("##{template}")
    throw Error("Template ##{template} not found!") unless tpl_nod?
    @template = utils.trim tpl_nod.html()
    window.Mustache.parse(@template)

  render: (data) ->
    nod = pi.Nod.create window.Mustache.render(@template,data)
    @_render nod, data