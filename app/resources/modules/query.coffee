do (context = this) ->
  "use strict"

  # shortcuts
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  # add query method to resource
  # ! query data is not cached in resource (in '__all__')
  #  if you want to cache resources use 'fetch' with params

  class pi.resources.Query
    @extended: (klass) ->
      klass.query_path = klass.fetch_path

    @query: (params) ->
      @_request(@query_path, 'get', params).then( 
        (response) =>
          @on_query response
        ) 

    @on_query: (data) ->
      if data[@resources_name]?
        query_data = @build(el,true,false) for el in data[@resources_name]
