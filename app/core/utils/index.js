'use strict'
var utils = require('./base');

utils.arr = require('./arr');
utils.obj = require('./obj');
utils.promise = require('./promise');
utils.func = require('./func');
utils.browser = require('./browser');
utils.time = require('./time');

// logger extends base utils
require('./logger');

utils.matchers = require('./matchers');

module.exports = utils;
