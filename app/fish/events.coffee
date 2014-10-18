'use strict'
pi = require '../core'
require '../components/events/pi_events'
utils = pi.utils

utils.extend(pi.Events, 
  Opened: 'opened'
  Query: 'query'
  AS3_Event: 'as3_event'
  )