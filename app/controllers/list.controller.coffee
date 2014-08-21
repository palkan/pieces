'use strict'
pi = require '../core'
require './base'
require './page'
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
  # @params [String] action resource method name (fetch, create, destroy ...)
  # @params [Object] params query params

  query: (params={}) ->
    params = utils.merge(@scope().params,params) 
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
    if @scope().is_full
      @view.search q
    else
      @query().then(
        (data) =>
          @view.reload @_parse_response(data)
          @view.searched q
          data
      )

  sort: (params=null) ->
    sort_params = {sort: params}
    @scope().set sort_params
    if @scope().is_full
      @view.sort params
    else
      @query().then(
        (data) =>
          @view.reload @_parse_response(data)
          @view.sorted params
          data
      )

  filter: (params=null) ->
    filter_params = {filter: params}
    @scope().set filter_params
    if @scope().is_full
      @view.filter params
    else
      @query().then(
        (data) =>
          @view.reload @_parse_response(data)
          @view.filtered params
          data
      )
