'use strict'
pi = require '../../core'

pi.InputEvent = 
  Change: 'changed'
  Clear: 'cleared'
  Editable: 'editable'

pi.FormEvent =
  Update: 'updated'
  Submit: 'submited'
  Invalid: 'invalid'