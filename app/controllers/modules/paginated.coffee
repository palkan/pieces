'use strict'
pi = require '../../core'
require '../base'
utils = pi.utils


class pi.controllers.Paginated
  @included: (base) ->
    _query = base::query

    base::query = (params={}) ->
      unless params.page?
        params.page = @_page = 1
      params.per_page = @per_page

      _query.call(@,params).then(
        (data) =>
          @page_resolver data
          data
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
    @query(page: @_page).then(
      (data) => 
        @view.load @_parse_response(data)
        data
      )