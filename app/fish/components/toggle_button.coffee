'use strict'
pi = require '../../core'
require '../../components/base/base'
require '../../plugins/base/selectable'
utils = pi.utils

class pi.ToggleButton extends pi.Base
  @include_plugins pi.Base.Selectable