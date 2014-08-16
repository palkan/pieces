 do (context = this) ->
  "use strict"
  # shortcuts
  $ = context.$
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  _swf_count = 0

  class pi.SwfPlayer extends pi.Base
    initialize: ->
      cont = document.createElement 'div'

      @player_id = "swf_player_" + (++_swf_count)
      cont.id = @player_id
      @append cont
      
      @options.version ||= "11.0.0"

      @load(@options.url) if @options.url? and @enabled
      super

    load: (url, params={}) ->
      url ||= @options.url
      (params[key] = val) for key,val of @options when not params[key] 
      swfobject.embedSWF(url, @player_id, "100%", "100%", @options.version, "", params, {allowScriptAccess:true, wmode:'transparent'})
    
    clear: ->
      @empty()

    as3_call: (method,args...)->
      obj = swfobject.getObjectById @player_id
      if obj
        obj[method]?.apply(obj,args)

    as3_event: (e) ->
      utils.debug e
      @trigger 'as3_event', e