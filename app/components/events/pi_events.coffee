'use strict'
pi = require '../../core'
utils = pi.utils

pi.Events = 
  Initialized: 'initialized'
  Created: 'creation_complete'
  Destroyed: 'destroyed'
  Enabled: 'enabled' 
  Hidden: 'hidden'
  Active: 'active'
  Selected: 'selected'
  Update: 'update'
  SelectionCleared: 'selection_cleared'