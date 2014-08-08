do (context = this) ->
  "use strict"
  # shortcuts
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  _prepare_response = (xhr) ->
    type = xhr.getResponseHeader 'Content-Type'
    response = 
      if /json/.test type
        JSON.parse xhr.responseText
      else
        xhr.responseText
    response

  _is_success = (status) ->
     (status >= 200 and status <300) or (status is 304) 

  _data_to_params = 
    (data) ->
      params = []
      if data?
        params.push("#{ key }=#{ encodeURIComponent(val) }") for own key, val of data
      params

  _data_to_form = (
    if context.FormData?
      (data) ->
        form = new FormData()
        for own key,val of data
          form.append key, val
        form
    else
      _data_to_params
  )()

  pi.net = 
    use_json: true
    headers: []
    request: (method, url, data, options={}, xhr) ->
      new Promise( 
        (resolve, reject) ->
          req = xhr || new XMLHttpRequest()
          
          _headers = utils.merge pi.net.headers, (options.headers||{})

          if (method is 'GET')
            params = _data_to_params data
            url+="?#{ params.join("&") }"
            data = null
          else
            if pi.net.use_json  
              _headers['Content-Type'] = 'application/json'
              data = JSON.stringify(data) if data?
            else
              data = _data_to_form data

          req.open method, url, true
          req.setRequestHeader(key,value) for own key,value of _headers

          _headers = null

          req.onreadystatechange = ->

            return if req.readyState isnt 4 

            if _is_success(req.status)
              resolve _prepare_response(req)
            else
              reject Error(req.statusText)

  
          req.onerror = ->
            reject Error("Network Error")
            return
      
          req.send(data)
          )

    # Upload file using XHR
    # Available options:
    #   method [String] request method (default to POST)
    #   name [String] POST field name (default to 'file')
    #   headers [Object] Custom headers
    upload: (file, url, data = {}, options={}, xhr) ->
      new Promise(
        (resolve, reject, progress) ->
          req = xhr || new XMLHttpRequest()
          
          _headers = utils.merge pi.net.headers, (options.headers||{})

          options.name ||= 'file'
          
          form = new FormData()
          form.append options.name, file
          
          for own key,val of data
            form.append(key, val)
              
          if typeof options.progress is 'function'  
            req.upload.onprogress = (event) => 
              value = if event.lengthComputable then event.loaded * 100 / event.total else 0
              progress(Math.round(value)) if progress?

          req.onload = ->
            resolve _prepare_response(req)

          req.onerror = ->
            reject Error("Network Error: "+req.responseText)
            return
            
          req.open(options.method||'POST', url, true)
          req.withCredentials = !!options.withCredentials
          req.setRequestHeader(key,value) for own key,value of _headers

          req.send form
          )
    
  pi.net[method] = curry(pi.net.request, [method.toUpperCase()], null) for method in ['get', 'post', 'patch', 'delete']
