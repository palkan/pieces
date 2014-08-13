do (context = this) ->
  "use strict"

  class FormerJS
    constructor: (@nod, @options={}) ->
      @options.name_transform = @_rails_name_transform if @options.rails is true
      @options.parse_value = @_serialize if @options.serialize is true

    @parse: (nod, options) ->
      (new FormerJS(nod,options)).parse()

    @fill: (nod, options) ->
      (new FormerJS(nod,options)).fill()

    @clear: (nod, options) ->
      (new FormerJS(nod, options)).clear()

    parse: ->
      @_process_name_values @_collect_name_values()

    fill: (data) ->
      @_traverse_input_nodes @nod, (nod) => @_fill_nod nod, data

    clear: ->
      @_traverse_input_nodes @nod, (nod) => @_clear_nod nod


    _process_name_values: (name_values) ->
      _result = {}
      _arrays = {}

      for item in name_values
        do (item) =>
          {name: name, value: value} = item
          return if @options.skip_empty and (value is '' or value is null)
          
          _arr_fullname = ''

          _current = _result

          name = @options.name_transform(name) if @options.name_transform?

          value = @options.parse_value(value) if @options.parse_value? 

          _name_parts = name.split "."

          len = _name_parts.length

          for name_part,i in _name_parts
            do (name_part) =>
              
              if name_part.indexOf('[]') > -1
                _arr_name = name_part.substr(0, name_part.indexOf('['))
                _arr_fullname += _arr_name

                _current[_arr_name] ||= []

                if i is (len-1)
                  _current[_arr_name].push value
                else
                  _next_field = _name_parts[i+1]
                  _arrays[_arr_fullname] ||= []
                  
                  _arr_len = _arrays[_arr_fullname].length

                  if _current[_arr_name].length>0
                    _array_item = _current[_arr_name][_current[_arr_name].length-1] 

                  if (not _arr_len or ((_next_field in _arrays[_arr_fullname]) and not (_next_field.indexOf('[]')>-1 or !(_array_item[_next_field] && (i+1 == len-1)))))
                    _array_item = {}  
                    _current[_arr_name].push _array_item
                    _arrays[_arr_fullname] = []
                    
                  
                  _arrays[_arr_fullname].push _next_field
                  _current = _array_item
              else
                _arr_fullname += name_part

                if i < (len - 1) 
                  _current[name_part] ||= {}
                  _current = _current[name_part]
                else
                  _current[name_part] = value
      _result

    _collect_name_values: ->
      @_traverse_input_nodes @nod, (nod) => @_parse_nod nod

    _traverse_input_nodes: (nod, callback) ->
      result = @_to_array callback(nod)
      current = nod.firstChild
      
      while(current?)
        result = result.concat @_traverse_input_nodes(current,callback)
        current = current.nextSibling
      result

    _to_array: (val) ->
      if not val?
        []
      else if val instanceof Array
        val
      else
        [val]

    _parse_nod: (nod) ->
      return if @options.disabled is false and nod.disabled

      return if not /(input|select|textarea)/i.test nod.nodeName

      return if not nod.name

      val = @_parse_nod_value nod

      return if not val?

      name: nod.name, value: val

    _fill_nod: (nod, data) ->
      return if not /(input|select|textarea)/i.test nod.nodeName
      
      value = @_nod_data_value nod.name, data

      return if not value?

      if nod.nodeName.toLowerCase() is 'select'
        @_fill_select nod, value
      else
        return if typeof value is 'object'
        type = nod.type.toLowerCase()
        switch
          when (/(radio|checkbox)/.test(type) and value) then (nod.checked = true)  
          when (/(radio|checkbox)/.test(type) and not value) then (nod.checked = false)  
          else (nod.value = value)
      return

    _fill_select: (nod, value) ->
      value = if value instanceof Array then value else [value]
      for option in nod.getElementsByTagName("option")
        do (option) ->
          option.selected = (option.value in value)

    _clear_nod: (nod) ->
      return if not /(input|select|textarea)/i.test nod.nodeName
      
      if nod.nodeName.toLowerCase() is 'select'
        @_fill_select nod, []
      else
        type = nod.type.toLowerCase()
        switch
          when /(radio|checkbox)/.test(type) then (nod.checked = false)  
          when (type is 'hidden' and !@options.clear_hidden) then true
          else (nod.value = '')
      return

    _nod_data_value: (name, data) ->
      name = name.replace(@options.fill_prefix, '') if @options.fill_prefix
      name = @options.name_transform(name) if @options.name_transform?

      return if name.indexOf('[]')>-1

      for key in name.split(".")
          data = data[key]
          if not data?
            break
      data
      
    _parse_nod_value: (nod) ->
      if nod.nodeName.toLowerCase() is 'select'
        @_parse_select_value nod
      else
        type = nod.type.toLowerCase()
        switch
          when (/(radio|checkbox)/.test(type) and nod.checked) then nod.value  
          when (/(radio|checkbox)/.test(type) and not nod.checked) then null  
          when /(button|reset|submit|image)/.test(type) then null
          when /(file)/.test(type) then @_parse_file_value(nod)
          else nod.value

    _parse_file_value: (nod) ->
      unless nod.files.length
        return

      if nod.multiple
        nod.files
      else
        nod.files[0]
          
    _parse_select_value: (nod) ->
      multiple = nod.multiple

      return nod.value if not multiple

      option.value for option in nod.getElementsByTagName("option") when option.selected

    _rails_name_transform: (name) ->
      name.replace(/\[([^\]])/ig, ".$1").replace(/([^\[])([\]]+)/ig,"$1")

    _serialize: (val) ->
      val = switch
        when (not val? or val is '') then null
        when val == 'true' then true
        when val == 'false' then false
        when isNaN(Number(val)) then val 
        else Number(val)

     
  if (typeof define is 'function' and define.amd?)
    define(FormerJS)
  else if (typeof module is 'function')
    module.exports = FormerJS
  else
    context.FormerJS = FormerJS
