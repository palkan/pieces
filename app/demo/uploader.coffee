'use strict'
pi = require 'core'
require 'components/pieces'

class pi.Uploader extends pi.Base
  postinitialize: ->
    super
    @upload_btn.on 'click', =>
      return unless @form.btn.files().length
      @_start_upload()
      if false and pi.net.XHR_UPLOAD
        utils.debug 'XHR upload'
        data = FormerJS.parse @form.node
        pi.net.upload(@options.url, data).catch(
          (e) => @_upload_error e
        ).then(
          (response) => @_finish_upload response
        )
      else
        utils.debug 'IFrame upload'
        pi.net.iframe_upload(@form, @options.url).catch(
          (e) => @_upload_error e
        ).then(
          (response) => @_finish_upload response
        )

  _start_upload: ->
    @upload_btn.disable()
    @trigger 'upload_start'

  _upload_error: (e) ->
    utils.error e

  _finish_upload: (data) ->
    utils.info data
    @upload_btn.enable()

