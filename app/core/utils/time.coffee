'use strict'
utils = require './base'

_reg = /%[a-zA-Z]/g

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
  "e": (d) ->
    d.getDate()
  "P": (d) ->
    if d.getHours() > 11
      "PM"
    else 
      "AM"
  "p": (d) ->
    _formatter.P(d).toLowerCase()


# utils for working with time
utils.time =
  # Add new code with formatter,
  # which can be used to format strings.
  # 
  # Example:
  #   function even_date(d){
  #     d.getDate() % 2 == 0 ? 'even' : 'odd'
  #   }
  #   
  #   utils.time.add_formatter('E', even_date)
  add_formatter: (code, formatter) ->
    _formatter[code] = formatter
  # Parses t and returns Date object.
  # Simply calls Date constructor, but
  # can auto-detect seconds/milliseconds
  parse: (t) ->
    # convert to milliseconds if time was provided as number of seconds
    if typeof t is 'number' and t < 4000000000
      t*=1000
    new Date(t) # t can be date object or string or ts
 
  # Current time formated according to fmt.
  now: (fmt) ->
    @format(new Date(), fmt)

  # Format time according fmt.
  # Available interpolations:
  #   %H - hours (00-23)
  #   %I - hours (01-12)
  #   %l - hours (1-12)
  #   %M - minutes (00-59)
  #   %S - seconds (00-59)   
  #   %L - milliseconds (000-999)
  #   %z - timezone (+/- hours:minutes)
  #   %Y - year with century
  #   %y - year without century
  #   %m - month (1-12)
  #   %d - day of the month (01-31)
  #   %e - day of the month (1-31) 
  #   %P - median indicator ("AM"/"PM")
  #   %p - median indicator ("am"/"pm")

  format:(t, fmt) ->
    t = @parse(t)
    return t unless fmt?
    fmt.replace(_reg, (match) -> 
      code = match[1..]
      if _formatter[code]
        _formatter[code](t)
      else
        match
    )

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
