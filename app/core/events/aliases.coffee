'use strict'
pi = require '../pi'
require './nod_events'
Browser = require '../utils/browser' 

if !!Browser.info().gecko
  pi.NodEvent.register_alias 'mousewheel', 'DOMMouseScroll'