'use strict'
Base = require '../../components/base'
Plugin = require '../plugin'
utils = require '../../core/utils'
Renderers = require '../../renderers'

_renderer_reg = /(\w+)(?:\(([\w\-\/]+)\))?/

# Add render method to component; support simple templates 
class Base.Renderable extends Plugin
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
        utils.error "failed to render data for: #{@target.pid}}", data
    @target

  find_renderer: ->
    if @target.options.renderer? and _renderer_reg.test(@target.options.renderer)
      [_, name, param] = @target.options.renderer.match _renderer_reg
      klass = Renderers[utils.camelCase(name)]
      if klass?
        return new klass(param)
    else if (tpl = @target.find('.pi-renderer'))
      renderer = new Renderers.Simple(tpl)
      tpl.remove()
      return renderer
    new Renderers.Base()

module.exports = Base.Renderable
