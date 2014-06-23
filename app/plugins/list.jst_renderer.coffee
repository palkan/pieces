do (context = this) ->
  "use strict"
  # shortcuts
  $ = context.jQuery
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  # [Plugin]
  # Setup JST template as renderer for list by name
 
  class pi.JstRenderer
    constructor: (list) ->
      unless typeof list.item_renderer is 'string'
        utils.error 'JST renderer name undefined'
        return

      list.jst_renderer = JST[list.item_renderer]

      list.item_renderer = (data) ->
        item = utils.clone data
        item.nod = pi.Nod.create list.jst_renderer(data)
        item