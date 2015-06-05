'use strict'

var adapters = {};
adapters.AbstractStorage = require('./abstract');
adapters.REST = require('./rest');
module.exports = adapters;
