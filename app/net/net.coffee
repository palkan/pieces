'use strict'
utils = require '../core/utils'
IframeUpload = require './iframe.upload'
Nod = require('../core/nod').Nod

class Net
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
  
  @_is_app_error: (status) ->
    (status >= 400 and status < 500)

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
  @method_override: false
  
  @request: (method, url, data, options={}, xhr) ->
    new Promise( 
      (resolve, reject) =>
        req = xhr || new XMLHttpRequest()

        use_json = if options.json? then options.json else @use_json
        
        _headers = utils.merge @headers, (options.headers||{})

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
          # override methods
          if @method_override is true
            data._method = method 
            _headers['X-HTTP-Method-Override'] = method         
            method = 'POST'

          if use_json  
            _headers['Content-Type'] = 'application/json'
            data = JSON.stringify(data) if data?
          else
            data = @_data_to_form data

        req.open method, url, true
        req.withCredentials = !!options.withCredentials
        req.setRequestHeader(key,value) for own key,value of _headers

        _headers = null

        if typeof options.progress is 'function'  
          req.upload.onprogress = (event) => 
            value = if event.lengthComputable then event.loaded * 100 / event.total else 0
            options.progress(Math.round(value))


        req.onreadystatechange = =>

          return if req.readyState isnt 4 

          if @_is_success(req.status)
            resolve @_prepare_response(req)
          else if @_is_app_error(req.status)
            reject Error(@_prepare_error(req))
          else
            reject Error('500 Internal Server Error')


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
  #   as_json [Boolean] whether to parse response as json or not (default is equal to Net.use_json)

  @iframe_upload: (form, url, data={}, options={}) -> 
    as_json = if options.as_json? then options.as_json else @use_json

    form = Nod.create(form) unless form instanceof Nod

    throw Error('Form is undefined') unless form?

    method = options.method || 'POST'

    new Promise(
        (resolve, reject) =>
          IframeUpload.upload(form, url, @_to_params(data), method).then( 
            (response) => 
              reject Error('Response is empty') unless response?

              resolve(response.innerHtml) unless as_json

              response = 
                try
                  JSON.parse response.innerHTML
                catch e
                  JSON.parse response.innerText

              resolve response
          ).catch((e) -> reject e)
      )

Net.XHR_UPLOAD = !!window.FormData
Net.IframeUpload = IframeUpload
  
Net[method] = utils.curry(Net.request, [method.toUpperCase()], Net) for method in ['get', 'post', 'patch', 'put', 'delete']

module.exports = Net
