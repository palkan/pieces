'use strict'
pi = require 'core'
require './base/button'
require 'plugins/base/selectable'
utils = pi.utils

class pi.ToggleButton extends pi.Button
  @include_plugins pi.Base.Selectable

pi.Guesser.rules_for 'toggle_button', ['pi-toggle-button']