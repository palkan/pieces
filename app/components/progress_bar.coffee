do (context = this) ->
  "use strict"
  # shortcuts
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  class pi.ProgressBar extends pi.Base
    start: (target) ->
      @value = 0
      @show()

    set: (value) ->
      @value = value
      @style(width: "#{value}%")

    simulate: (speed = 200)->
      @_sid = after speed, =>
                @set (@value + (100 - @value)/2) 
                @simulate(speed)
    reset: ->
      @_sid && clearTimeout(@_sid)
      @style(width: 0)
      @hide()

    stop: ->
      @_sid && clearTimeout(@_sid)
      @style(width: "101%")
      after 200, =>
        @style(width: 0)
        @hide()

  pi.Guesser.rules_for 'progress_bar',['pi-progressbar']