do (context = this) ->
  "use strict"
  # shortcuts
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  class pi.ToggleButton extends pi.Button
    @include_plugins pi.Base.Selectable

  pi.Guesser.rules_for 'toggle_button', ['pi-toggle-button']