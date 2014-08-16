do (context = this) ->
  "use strict"
  # shortcuts
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  # [Plugin]
  # Select elements OS-like (mouse_down -> move -> mouse_up)
 
  class pi.List.MoveSelect extends pi.Plugin
    id: 'move_select'
    initialize: (@list) ->
      super
      unless @list.has_selectable
        @list.attach_plugin pi.List.Selectable

      @_direction = @list.options.direction || 'y'
      
      @list.on 'mousedown', @mouse_down_listener()

    _item_under_point: (point) ->
      @_item_bisearch 0, point[@_direction], point

    _item_bisearch: (start, delta, point) ->
      index_shift = ((delta/@_height)*@_len)|0

      if index_shift is 0
        index_shift = if delta > 0 then 1 else -1 

      index = start+index_shift

      if index<0
        return 0

      if index>@_len-1
        return (@_len-1)

      item = @list.items[index]

      match = @_item_match_point item, point

      if match is 0
        index
      else
        @_item_bisearch index, match, point

    _item_match_point: (item, point) ->
      
      {x: item_x, y: item_y} = item.position()

      pos = {x: item_x - @_offset.x, y: item_y - @_offset.y}
      param = if @_direction is 'y' then item.height() else item.width()

      if (point[@_direction] >= pos[@_direction] and pos[@_direction] + param > point[@_direction])
        0  
      else
        point[@_direction] - pos[@_direction]

    _update_range: (index) ->
      return if index is @_last_index

      if (@_last_index-@_start_index)*(index-@_start_index) < 0
        @_update_range @_start_index

      utils.debug "next index: #{index}; last index: #{@_last_index}; start: #{@_start_index}"

      downward = (index - @_last_index) > 0

      below = if @_last_index isnt @_start_index then (@_last_index - @_start_index) > 0 else downward

      utils.debug "below: #{below}; downward: #{downward}"

      switch 
        when downward and below then @_select_range @_last_index+1, index
        when not downward and not below then @_select_range index, @_last_index-1
        when downward and not below then @_clear_range @_last_index, index-1  
        else @_clear_range index+1, @_last_index

      @_last_index = index

    _clear_range: (from, to) ->
      @list.deselect_item(item) for item in @list.items[from..to]

    _select_range: (from, to) ->
      @list.select_item(item) for item in @list.items[from..to]

    mouse_down_listener: ->
      @_mouse_down_listener ||= (e) =>
        {x: _x, y: _y} = @list.items_cont.position()
        @_offset = x: _x, y: _y
        @_start_point = x: e.pageX-_x, y: e.pageY-_y

        @_wait_drag = after 300, =>
          @_height = @list.height()
          @_len = @list.items.length
          @_start_index = @_item_under_point @_start_point
          @_last_index = @_start_index
          
          @list.clear_selection(true)
          @list.select_item @list.items[@_start_index]
          
          @list.trigger 'selected'

          @list.on 'mousemove', @mouse_move_listener()
          @_moving = true
        
        pi.Nod.root.on 'mouseup', @mouse_up_listener()

    mouse_up_listener: ->
      @_mouse_up_listener ||= (e) =>
        
        pi.Nod.root.off 'mouseup', @mouse_up_listener()
        
        if @_moving
          @list.off 'mousemove', @mouse_move_listener()
          @_moving = false
          e.stopImmediatePropagation()
          e.preventDefault()
        else clearTimeout(@_wait_drag)
    
    mouse_move_listener: ->
      @_mouse_move_listener ||= debounce 300, (e) =>
        point = x: e.pageX-@_offset.x, y: e.pageY-@_offset.y
        @_update_range @_item_under_point(point)