'use strict'
pi = require '../../core'
require '../../components/pieces'
require '../plugin'
utils = pi.utils

_renderer_reg = /(\w+)(?:\(([\w\-\/]+)\))?/

# [Plugin]
# Add  js templates ('render(data)')
class pi.Base.Renderable extends pi.Plugin
  id: 'renderable'

  @included: (klass) ->
    self = @
    klass.before_initialize -> @attach_plugin self

  initialize: (@target) ->
    super
    @target._renderer = @find_renderer()
    @target.delegate_to @, 'render'
    @

  render: (data) ->
    @target.remove_children()
    if data?
      nod = @target._renderer.render data, false
      if nod?
        @target.append nod
        @target.piecify(@target)
      else
        utils.error "failed to render data for: #{@target.pid}}"
    @target

  find_renderer: ->
    if @target.options.renderer? and _renderer_reg.test(@target.options.renderer)
      [_, name, param] = @target.options.renderer.match _renderer_reg
      klass = pi.Renderers[utils.camelCase(name)]
      if klass?
        return new klass(param)
    new pi.Renderers.Base()