'use strict'
pi = require '../../core'
require '../base'
utils = pi.utils


class pi.controllers.Paginated
  @included: (base) ->
    base::query = (_params={}, scope_params={}, next_page = false) ->
      unless _params.page?
        _params.page = @_page = 1
      _params.per_page = @per_page

      unless @_promise?
        @_promise = utils.resolved_promise()

      @_promise = @_promise.then( (data) =>
        @scope().set scope_params
        if @scope().is_full
          utils.resolved_promise()
        else
          params = utils.merge(@scope().params,_params) 
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
   
    @query(page: @_page, {}, true).then(
      ((data) => 
        @view.load(@_parse_response(data)) if data?
        data
      )
    )
