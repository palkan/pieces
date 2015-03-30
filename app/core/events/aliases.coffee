'use strict'
NodEvent = require('../nod').NodEvent
Browser = require '../utils/browser' 

if !!Browser.info().gecko
  NodEvent.register_alias 'mousewheel', 'DOMMouseScroll'
