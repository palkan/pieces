do (context = this) ->
  "use strict"
  # shortcuts
  $ = context.jQuery
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  # [Plugin]
  # Setup JST template as renderer for list by name
 
  class pi.List.JstRenderer extends pi.Plugin
    initialize: (@list) ->
      super
      if @list.options.renderer and JST[@list.options.renderer]
        @list.delegate_to 'jst_renderer', 'item_renderer'

    item_renderer: (data) ->
      data = utils.clone data
      item = pi.Nod.create JST[@list.options.renderer](data)
      item = item.piecify()
      utils.extend item, data 
      item