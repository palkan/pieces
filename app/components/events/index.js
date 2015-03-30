var events = require('./pi_events'),
    utils = require('../../core/utils');

utils.extend(events, require('./input_events'));
module.exports = events;
