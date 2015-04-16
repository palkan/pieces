'use strict'

var utils = require('../core/utils');

var resources = {};
resources.Base = require('./base');
resources.View = require('./view');
resources.Association = require('./association');
resources.REST = require('./rest');

utils.extend(resources, require('./modules'));

require('./utils/binding');

module.exports = resources;
