do (context = this) ->
  "use strict"
  # shortcuts
  $ = context.jQuery
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  # [Plugin]
  # Setup JST template as renderer for list by name
 
  class pi.List.JstRenderer extends pi.Plugin
    item_renderer: (data) ->
      item = utils.clone data
      item.nod = pi.Nod.create JST[@options.renderer](data)
      item