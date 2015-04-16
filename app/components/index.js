'use strict'
var components = {};
components.Events = require('./events');
components.Base = require('./base');
require('./utils/binding');
components.BaseInput = require('./base_input');
components.TextInput = require('./text_input');
components.Form = require('./form')
module.exports = components;
