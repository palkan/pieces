'use strict'
pi = require '../core'
utils = pi.utils

class pi.Net
  @_prepare_response: 
    (xhr) ->
      type = xhr.getResponseHeader 'Content-Type'
      response = 
        if /json/.test type
          JSON.parse xhr.responseText
        else
          xhr.responseText
      utils.debug 'XHR response', xhr.responseText
      response

  @_prepare_error: (xhr) ->
    type = xhr.getResponseHeader 'Content-Type'
    response = 
      if /json/.test type
        JSON.parse xhr.responseText || """{"status":#{xhr.statusText}}"""
      else
        xhr.responseText || xhr.statusText
    

  @_is_success: 
    (status) ->
      (status >= 200 and status <300) or (status is 304) 

  @_with_prefix: (prefix,key) ->
    if prefix
      "#{prefix}[#{key}]"
    else
      key

  @_to_params: 
    (data,prefix="") ->
      params = []
      
      if not data? 
        return params

      if typeof data isnt 'object'    
        params.push({name: prefix, value: data})
      else
        if data instanceof Date
          params.push({name: prefix, value: data.getTime()})
        else if data instanceof Array
          prefix+="[]"
          for item in data
            params = params.concat @_to_params item, prefix
        # IE hach: instanceof throws Reference error if argument is undefined
        else if (!!window.File and ((data instanceof File) or (data instanceof Blob)))
          params.push({name: prefix, value: data})
        else
          for own key, val of data
            params = params.concat @_to_params(val, @_with_prefix(prefix,key))
      params

  @_data_to_query:
    (data) ->
      q = []
      for param in @_to_params(data)
        q.push "#{param.name}=#{encodeURIComponent(param.value)}"
      q.join "&"

  @_data_to_form: 
    (
      if !!window.FormData
        (data) =>
          form = new FormData()
          for param in @_to_params(data)
            form.append param.name, param.value
          form
      else
        (data) => @_data_to_query data
    )

  @use_json: true
  @headers: []
  
  @request: (method, url, data, options={}, xhr) ->
    new Promise( 
      (resolve, reject, progress) =>
        req = xhr || new XMLHttpRequest()

        use_json = if options.json? then options.json else @use_json
        
        _headers = utils.merge pi.net.headers, (options.headers||{})

        if (method is 'GET')
          q = @_data_to_query data
          if q
            if url.indexOf("?")<0
              url+="?"
            else
              url+="&"
            url+="#{ q }"
          data = null
        else
          if use_json  
            _headers['Content-Type'] = 'application/json'
            data = JSON.stringify(data) if data?
          else
            data = @_data_to_form data

        req.open method, url, true
        req.withCredentials = !!options.withCredentials
        req.setRequestHeader(key,value) for own key,value of _headers

        _headers = null

        if typeof progress is 'function'  
          req.upload.onprogress = (event) => 
            value = if event.lengthComputable then event.loaded * 100 / event.total else 0
            progress(Math.round(value)) if progress?


        req.onreadystatechange = =>

          return if req.readyState isnt 4 

          if @_is_success(req.status)
            resolve @_prepare_response(req)
          else
            reject Error(@_prepare_error(req))


        req.onerror = =>
          reject Error("Network Error")
          return
    
        req.send(data)
        )

  # Upload file using XHR
  # Available options:
  #   method [String] request method (default to POST)
  #   headers [Object] Custom headers
  @upload: (url, data = {}, options={}, xhr) ->
    throw Error('File upload not supported') unless @XHR_UPLOAD

    method = options.method||'POST'
    options.json = false

    @request method, url, data, options, xhr
    
  # Upload file using IFrame
  # Available options:
  #   method [String] request method (default to POST) 
  #   as_json [Boolean] whether to parse response as json or not (default is equal to pi.Net.use_json)

  @iframe_upload: (form, url, data={}, options={}) -> 
    as_json = if options.as_json? then options.as_json else @use_json

    form = pi.Nod.create(form) unless form instanceof pi.Nod

    throw Error('Form is undefined') unless form?

    method = options.method || 'POST'

    new Promise(
        (resolve, reject) =>
          pi.net.IframeUpload.upload(form, url, @_to_params(data), method).then( 
            (response) => 
              reject Error('Response is empty') unless response?

              resolve(response.innerHtml) unless as_json

              response = JSON.parse response.innerHTML
              resolve response
          ).catch((e) -> reject e)
      )

pi.Net.XHR_UPLOAD = !!window.FormData

# backward compatibility
pi.net = pi.Net
  
pi.net[method] = utils.curry(pi.net.request, [method.toUpperCase()], pi.net) for method in ['get', 'post', 'patch', 'delete']
