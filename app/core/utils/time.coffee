'use strict'
utils = require './base'

_reg = /%([a-zA-Z])/g

_splitter = ( ->
  if "%a".split(_reg).length is 0
    (str) ->
      matches = str.match _reg
      parts = str.split _reg
      res = []
      if str[0] is "%"
        res.push "", matches.shift()[1]
      len = matches.length + parts.length
      flag = false
      while len>0
        res.push if flag then matches.shift()[1] else parts.shift()
        flag = !flag
        len--
      res 
  else
    (str) ->
      str.split _reg
)()

_pad = (val, offset = 1) ->
  n = 10
  while offset 
    val = "0"+val if val < n
    n*=10
    offset--
  val

_formatter =
  "H": (d) -> 
    _pad(d.getHours())
  "k": (d) ->
    d.getHours()
  "I": (d) ->
    _pad _formatter.l(d)
  "l": (d) ->
    h = d.getHours()
    if h > 12 then h-12 else h 
  "M": (d) ->
    _pad(d.getMinutes())
  "S": (d) ->
    _pad(d.getSeconds())
  "L": (d) ->
    _pad(d.getMilliseconds(),2)
  "z": (d) ->
    offset = d.getTimezoneOffset()
    sign = if offset > 0 then "-" else "+"
    offset = Math.abs offset
    sign + _pad(Math.floor(offset/60))+":"+_pad(offset % 60)
  "Y": (d) ->
    d.getFullYear()
  "y": (d) ->
    (d.getFullYear()+"")[2..]
  "m": (d) ->
    _pad(d.getMonth()+1)
  "d": (d) ->
    _pad(d.getDate())
  "P": (d) ->
    if d.getHours() > 11
      "PM"
    else 
      "AM"
  "p": (d) ->
    _formatter.P(d).toLowerCase()

utils.time = 
  normalize_time: (t) ->
    # convert to milliseconds if time was provided as number of seconds
    if typeof t is 'number' and t < 4000000000
      t*=1000
    new Date(t) # t can be date object or string or ts
 
  now: (fmt) ->
    @format(new Date(), fmt)

  format:(t, fmt) ->
    t = @normalize_time(t)
    return t unless fmt?
    fmt_arr = _splitter fmt
    flag = false
    res = ""
    for i in fmt_arr 
      res+= (if flag then _formatter[i].call(null,t) else i)
      flag = !flag
    res

  # return string representing given time as duration ('%H:%M:%S(.%L)')
  duration: (val, milliseconds = false, show_milliseconds = false) ->
    if milliseconds
      ms = val % 1000
      val = (val/1000)|0
    arr = []
    m = (val/60)|0
    # add hours
    arr.push((m / 60)|0)
    # add minutes
    arr.push(_pad(m % 60))
    # add seconds
    arr.push(_pad(val % 60))
    res = arr.join(":")
    if ms? and show_milliseconds
      res+=".#{_pad(ms,2)}"
    res

module.exports = utils.time
