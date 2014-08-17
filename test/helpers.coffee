class TestHelpers
  @mouseEventElement: (el,type, x=0, y=0) ->
    ev = document.createEvent "MouseEvent"
    ev.initMouseEvent(
      type,
      true, #bubble 
      true, #cancelable
      window, null,
      0, 0, x, y, # coordinates
      false, false, false, false,  # modifier keys 
      0 # left
      null
    )
    el.dispatchEvent ev 
    return

  @clickElement: (el) ->
    TestHelpers.mouseEventElement el, "click"
    return

  @keyEvent: (nod, type, code) ->
    code = code.charCodeAt(0) if typeof code is 'string'
    ev = document.createEvent "KeyboardEvent"
    ev.initKeyboardEvent(type, true, true, null, 0, false, 0, false, code, 0) 
    nod.native_event_listener ev
    return

  @scrollEvent: (el) ->
    ev = document.createEvent "Event"
    ev.initEvent(
      'scroll',
      true, #bubble 
      true #cancelable
    )
    el.dispatchEvent ev 
  @mock_net: ->
    pi._orig_net = pi.net
    pi.net = (pi._mock_net ||= ( ->
      net =
        request: (method, url, data, options) ->
          new Promise(
            (resolve, reject) ->
              req = new XMLHttpRequest()
             
              params = []
              if data?
                params.push("#{ key }=#{ encodeURIComponent(val) }") for own key, val of data
            
              params = "#{ params.join("&") }"

              fake_url="/support/#{ url.replace(/\//g,"_") }"
             
              req.open 'GET', fake_url, true
              
              req.onreadystatechange = ->

                return if req.readyState isnt 4 

                if req.status is 200
                  response = JSON.parse req.responseText
                  method = method.toLowerCase()
                  resolve(if response[method]? then response[method] else response["default"])
                else
                  reject Error(req.statusText)
        
              req.onerror = ->
                reject Error("Network Error")
                return
            
              req.send(null)
          )
      net[method] = curry(net.request, [method.toUpperCase()], net) for method in ['get', 'post', 'patch', 'delete']
      net
      )())
    return
  @unmock_net: ->
    pi.net = pi._orig_net

module.exports = TestHelpers