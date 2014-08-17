'use strict'
pi = require 'core'
require '../pieces'
utils = pi.utils

class pi.Button extends pi.Base

pi.Guesser.rules_for 'button', ['pi-button'], ['button','a','input[button]']