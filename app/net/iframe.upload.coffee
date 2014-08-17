pi = require 'core'
require './net'
utils = pi.utils

class pi.net.IframeUpload
  @_build_iframe = (id) ->
    iframe = pi.Nod.create 'iframe'
    iframe.attrs id: id, name: id, width: 0, height: 0, border: 0
    iframe.styles {width: 0, height: 0, border: 'none'}
    iframe

  @_build_input = (name, value) ->
    input = pi.Nod.create 'input'
    input.node.type = 'hidden'
    input.node.name = name
    input.node.value = value
    input

  @_build_form = (form, iframe, params, url, method) ->
    form.attrs target: iframe, action: url, method: method, enctype: "multipart/form-data", encoding: "multipart/form-data"
    for param in params
      form.append @_build_input(param.name,param.value)
    form.append @_build_input('__iframe__',iframe)
    form
  
  @upload: (form, url, params, method) ->
    new Promise(
      (resolve) =>
        iframe_id = "iframe_#{ utils.uid()}"
        iframe = @_build_iframe(iframe_id)
        form = @_build_form(form, iframe_id, params, url, method)
        pi.Nod.body.append iframe

        iframe.on "load", ->
          if iframe.node.contentDocument.readyState is 'complete'
            response = iframe.node.contentDocument.getElementsByTagName("body")[0]
            utils.after 500, -> iframe.remove()
            iframe.off()
            resolve response

        form.node.submit()
    )