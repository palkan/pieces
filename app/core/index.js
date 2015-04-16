'use strict'
var pi = {}

// export function to global object (window) with ability to rollback (noconflict)
var _conflicts = {}

pi.export = function(fun, as){
  if(window[as] && !_conflicts[as])
    _conflicts[as] = window[as];
  window[as] = fun;
};

pi.noconflict = function(){
  for (var name in _conflicts){
    if(_conflicts.hasOwnProperty(name)){
      window[name] = _conflicts[name];
    }
  }
};

pi.config = require('./config');

var utils = pi.utils = require('./utils');

// export functions 
pi.export(utils.curry, 'curry');
pi.export(utils.delayed, 'delayed');
pi.export(utils.after, 'after');
pi.export(utils.debounce, 'debounce');
pi.export(utils.throttle, 'throttle');

pi.Core = require('./core');

pi.Events = require('./events');

var NodClasses = require('./nod');

pi.Nod = NodClasses.Nod;

utils.extend(pi.Events, NodClasses, false, ['Nod']);

pi.Events.ResizeDelegate = require('./events/resize_delegate');

pi.Events.NodEvent.register_delegate('resize', new pi.Events.ResizeDelegate());

// setup event aliases
require('./events/aliases');

pi.bindings = require('./binding');

module.exports = pi;
