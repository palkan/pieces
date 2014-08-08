do (context = this) ->
  "use strict"
  # shortcuts
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  class pi.Button extends pi.Base


  pi.Guesser.rules_for 'button', ['button'], ['button','a','input[button]']