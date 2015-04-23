'use strict'
Core = require '../../core/core'
utils = require '../../core/utils'
Base = require '../base'

class ParamsFilter extends Core
  @included: (base) ->
    base.extend @
    base::attributes = utils.func.prepend(
      base::attributes,
      (
        ->
          if @__dirty__ && @__filter_params__
            @__attributes__ = utils.extract(@, @__filter_params__)
      ),
      break_if_value: true
    )

  # define which attributes should be sent to server
  # e.g. params('id','name',{tags: ['name','id']})
  @params: (args...) ->
    if not @::hasOwnProperty("__filter_params__")
      @::__filter_params__ = []
      @::__filter_params__.push('id')
    @::__filter_params__ = @::__filter_params__.concat args

module.exports = ParamsFilter
