'use strict'
pi = require '../../core'
require '../../components/base/list'
require '../../plugins/plugin'
utils = pi.utils

_points_match = (point, pos, axis, param) ->
  (point[axis] >= pos[axis]) and (pos[axis] + param > point[axis])

# [Plugin]
# Get list item under point (x,y)
class pi.List.ItemUnderPoint extends pi.Plugin
  id: 'item_under_point'
  initialize: (@list) ->
    super
    @list.delegate_to @, 'item_under_point'
    @

  item_under_point: (point) ->
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
    else if match is false
      null
    else
      @_item_bisearch index, match, point

  _item_match_point: (item, point) ->
    
    {x: item_x, y: item_y} = item.position()

    pos = {x: item_x - @_offset.x, y: item_y - @_offset.y}

    xmatch = _points_match(point, pos, 'x', item.width()) 
    ymatch = _points_match(point,pos,'y',item.height())
    if xmatch and ymatch
      0  
    else if !xmatch and !ymatch
      false
    else if xmatch
      {x: point.x - pos.x, y: 0}
    else
      {y: point.y - pos.y, x: 0}