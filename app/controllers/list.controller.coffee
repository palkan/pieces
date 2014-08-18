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
    @has_resource resource

  id: 'list_base'

  initialize: ->
    super

  # Makes AJAX request on resource
  # @params [String] action resource method name (fetch, create, destroy ...)
  # @params [Object] params query params

  _action: (action) ->
    params = utils.clone @scope().params 
    @view.loading true

    @resources[action].call(@resources,params)
    .catch( (error) => @view.error error.message )
    .then( (response) =>  
      @view.loading false 
      response
      )
    .then( (response) => 
      @view.success(response.message) if response?.message?
      response
    )

  index: (params={}) ->
    @scope().set params
    @_action('fetch').then(
     (data) => 
        @view.reload data 
        data
    )

  search: (q) ->
    @scope().set({q: q})
    if @scope().is_full
      @view.search q
    else
      @_action('query').then(
        (data) =>
          @view.reload data
          @view.searched q
          data
      )

  sort: (params=null) ->
    sort_params = {sort: params}
    @scope().set sort_params
    if @scope().is_full
      @view.sort params
    else
      @_action('query').then(
        (data) =>
          @view.reload data
          @view.sorted params
          data
      )

  filter: (params=null) ->
    filter_params = {filter: params}
    @scope().set filter_params
    if @scope().is_full
      @view.filter params
    else
      @_action('query').then(
        (data) =>
          @view.reload data
          @view.filtered params
          data
      )
