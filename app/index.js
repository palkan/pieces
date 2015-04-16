'use strict'
var pi = require('./core');

pi.Compiler = require('./grammar/compiler');

pi.components = require('./components');

pi.export(pi.components, "$c");

var BaseComponent = require('./components/base');
var Renderable = require('./components/modules/renderable');

BaseComponent.include(Renderable);

pi.klass = require('./components/utils/klass');

pi.renderers = require('./renderers');



pi.Plugin = require('./plugins');

pi.Net = require('./net');

pi.resources = require('./resources');

pi.export(pi.resources, "$r");

pi.controllers = require('./controllers');

pi.views = require('./views');

pi.Initializer = require('./components/utils/initializer');
require('./controllers/initializer');

pi.Guesser = require('./components/utils/guesser');

// setup application
pi.$ = require('./components/utils/setup');

// export pi.$ to global scope
pi.export(pi.$, '$')

var App = require('./core/app')

pi.app = new App();

module.exports = (window.pi = pi);
