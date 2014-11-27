'use strict'
pi = require '../../../core'
require '../../../controllers/base'
utils = pi.utils


class pi.controllers.Paginated
  @included: (base) ->
    base::query = (_params={}, next_page = false) ->
      params = utils.merge(@scope().params,_params) 
      
      unless params.page?
        params.page = @_page = 1
      params.per_page = @per_page

      unless @_promise?
        @_promise = utils.resolved_promise()

      @_promise = @_promise.then( (data) =>
        if @scope().is_full
          utils.resolved_promise()
        else
          @_resource_query(params).then(
            (data) =>
              @page_resolver data
              data
          )
      )

    base::scope_blacklist.push 'page', 'per_page'
    return

  # page resolver proccess server response to detect whether all data was loaded
  page_resolver: (data) ->
    if (list = @_parse_response(data))? and list.length < @per_page
      @scope().all_loaded()

  per_page: 40

  next_page: ->
    return if @scope().is_full
    
    @_page =  (@_page||0)+1
   
    @query(page: @_page, true).then(
      ((data) => 
        @view.load @_parse_response(data) if data?
        data
      )
    )
