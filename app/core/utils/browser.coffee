'use strict'

_mac_os_version_rxp = /\bMac OS X ([\d\._]+)\b/
_win_version_rxp = /\bWindows NT ([\d\.]+)\b/
_ios_rxp = /(iphone|ipod|ipad)/i
_ios_version_rxp = /\bcpu\s*(?:iphone\s+)?os ([\d\.\-_]+)\b/i
_android_version_rxp = /\bandroid[\s\-]([\d\-\._]+)\b/i
_win_version =
  '6.3': '8.1'
  '6.2': '8'
  '6.1': '7'
  '6.0': 'Vista'
  '5.2': 'XP'
  '5.1': 'XP'

# browser utils (requires bowser)
class browser
  @scrollbar_width: ->
    @_scrollbar_width ||= 
      do ->
        outer = document.createElement 'div'
        outerStyle = outer.style
        outerStyle.position = 'absolute'
        outerStyle.width = '100px'
        outerStyle.height = '100px'
        outerStyle.overflow = "scroll"
        outerStyle.top = '-9999px'
        document.body.appendChild outer
        w = outer.offsetWidth - outer.clientWidth
        document.body.removeChild outer
        w

  @info: ->
    unless @_info
      @_info =
        if window.bowser?
          @_extend_info(window.bowser)
        else
          @_extend_info()
    @_info

  @_extend_info: (data={})->
    data.os = @os()
    data

  @os: ->
    @_os ||= 
      do ->
        res = {}
        ua = window.navigator.userAgent

        if ua.indexOf('Windows')>-1
          res.windows = true
          if matches = _win_version_rxp.exec(ua)
            res.version = _win_version[matches[1]]
        else if ua.indexOf('Macintosh')>-1
          res.macos = true
          if matches = _mac_os_version_rxp.exec(ua)
            res.version = matches[1]
        else if ua.indexOf('X11')>-1
          res.unix = true
        else if matches = _ios_rxp.exec(ua)
          res[matches[1]] = true
          if matches = _ios_version_rxp.exec(ua)
            res.version = matches[1]
        else if ua.indexOf('Android')>-1
          res.android = true
          if matches = _android_version_rxp.exec(ua)
            res.version = matches[1]
        else if ua.indexOf('Tizen')>-1
          res.tizen = true
        else if ua.indexOf('Blackberry')>-1
          res.blackberry = true

        if res.version
          res.version = res.version.replace(/(_|\-)/g,".")
        res

module.exports = browser
