'use strict'

var utils = require('../core/utils');

var resources = {};
resources.Base = require('./base');
resources.View = require('./view');
resources.Association = require('./association');

var Storage = require('./storage');
resources.Base.include(Storage);

utils.extend(resources, require('./adapters'));
utils.extend(resources, require('./modules'));

resources.Base.include(resources.ParamsFilter);

require('./utils/binding');

module.exports = resources;
