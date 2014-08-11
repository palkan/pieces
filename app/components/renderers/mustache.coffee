do (context = this) ->
  "use strict"
  # shortcuts
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  # [Renderer]
  # Mustache based renderer
 
  class pi.List.Renderers.Mustache extends pi.List.Renderers.Base
    constructor: (template) ->
      throw Error('Mustache not found') unless context.Mustache?

      tpl_nod = $("##{template}")
      throw Error("Template ##{template} not found!") unless tpl_nod?
      @template = utils.trim tpl_nod.html()
      context.Mustache.parse(@template)

    render: (data) ->
      nod = pi.Nod.create context.Mustache.render(@template,data)
      @_render nod, data