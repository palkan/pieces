'use strict'
pi = require '../../core'
require '../../controllers/base'
require '../../controllers/page'
require './modules/scoped'
utils = pi.utils
page = pi.app.page

class pi.controllers.ListController extends pi.controllers.Base
  @include pi.controllers.Scoped

  # has_resource + define resource as list resource for index, search, filter and sort functions
  @list_resource: (resource) ->
    @::resources = resource
    @::_parse_response = (data) -> data[resource.resources_name]
    @has_resource resource

  id: 'list_base'

  default_scope: {}

  initialize: ->
    @scope().set @default_scope
    super

  # Makes AJAX request on resource
  # @params [Object] params query params

  query: (params={}) ->
    params = utils.merge(@scope().params,params) 
    
    unless @_promise?
      @_promise = utils.resolved_promise()

    @_promise = @_promise.then( =>
      if @scope().is_full
        utils.resolved_promise()
      else
        @_resource_query(params)
    )

  _resource_query: (params) ->
    @view.loading true
    @resources.query(params).then(
      ( 
        (response) => 
          @view.loading false 
          @view.success(response.message) if response?.message?
          response
      ),
      (
        (error) => 
          @view.loading false
          @view.error error.message 
          throw error
      )
    )

  index: (params) ->
    @scope().set(params)
    @query().then(
     (data) => 
        @view.load @_parse_response(data)
        data
    )

  search: (q) ->
    @scope().set({q: q})
    @query().then(
      (data) =>
        if data?
          @view.reload @_parse_response(data)
          @view.searched q
          data
        else
          @view.search(q)
        data
    )

  sort: (params=null) ->
    sort_params = {sort: params}
    @scope().set sort_params
    @query().then(
      (data) =>
        if data?
          @view.reload @_parse_response(data)
          @view.sorted params
          data
        else
          @view.sort(params)
        data
    )

  filter: (params=null) ->
    filter_params = {filter: params}
    @scope().set filter_params
    @query().then(
      (data) =>
        if data?
          @view.reload @_parse_response(data)
          @view.filtered params
          data
        else
          @view.filter(params)
        data
    )
