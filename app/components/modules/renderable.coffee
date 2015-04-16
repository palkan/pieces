'use strict'
utils = require '../../core/utils'
Nod = require('../../core/nod').Nod
Core = require '../../core/core'
Renderers = require '../../renderers'

class Renderable extends Core
  @included: (base) ->
    base.getset('renderer', (-> @__renderer__ ||= @_find_renderer()), ((val) -> @__renderer__ = val))

  render: (data) ->
    # invoke renderer before remove_children
    tpl = @renderer
    @remove_children()
    if data?
      nod = tpl.render data, false
      if nod?
        @append nod
        @piecify()
      else
        utils.error "failed to render data for: #{@pid}}", data
    @

  _find_renderer: ->
    if @options.renderer? and _renderer_reg.test(@options.renderer)
      [_, name, param] = @options.renderer.match _renderer_reg
      klass = Renderers[utils.camelCase(name)]
      if klass?
        return new klass(param)
    else if (tpl = @find('.pi-renderer'))
      renderer = new Renderers.Simple(tpl, @options.tpl_tag || tpl.data('tag'))
      tpl.remove()
      return renderer
    new Renderers.Base()

module.exports = Renderable
