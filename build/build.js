(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
'use strict';

Object.defineProperty(exports, '__esModule', {
  value: true
});

function _interopExportWildcard(obj, defaults) { var newObj = defaults({}, obj); delete newObj['default']; return newObj; }

function _defaults(obj, defaults) { var keys = Object.getOwnPropertyNames(defaults); for (var i = 0; i < keys.length; i++) { var key = keys[i]; var value = Object.getOwnPropertyDescriptor(defaults, key); if (value && value.configurable && obj[key] === undefined) { Object.defineProperty(obj, key, value); } } return obj; }

var _string = require('./string');

_defaults(exports, _interopExportWildcard(_string, _defaults));

},{"./string":2}],2:[function(require,module,exports){
'use strict';

/**
 * Return unique string with prefix (if provided)
 * 
 * @example 
 *  uid() #=> "101"
 *  uid() #=> "102" 
 *  uid("pre") #=> "pre103"
 *
 * @param {String} [pref]
 * @return {String}
 */

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.uid = uid;
exports.camelize = camelize;
exports.capitalize = capitalize;
exports.underscore = underscore;
exports.serialize = serialize;
exports.stripQuotes = stripQuotes;
exports.squish = squish;
var _uniq_id = 100;

function uid() {
  var pref = arguments.length <= 0 || arguments[0] === undefined ? "" : arguments[0];

  return '' + pref + ++_uniq_id;
}

;

function toUp(str) {
  return str ? str.toUpperCase() : '';
}

/**
 * Convert string from underscore to camel case
 * 
 * @example 
 *  camelize('my_name') #=> "MyName"
 *
 * @param {String} str
 * @return {String}
 */

function camelize(str) {
  return ('' + str).replace(/-(\w)/g, toUp);
}

/**
 * Convert the first letter of a string to upper case
 * 
 * @example 
 *  capitalize('my name') #=> "My name"
 *
 * @param {String} str
 * @return {String}
 */

function capitalize(str) {
  if (!str) return;
  return str.substring(0, 1).toUpperCase() + str.substring(1);
}

/**
 * Convert string to underscore from came case
 * 
 * @example 
 *  underscore('MyName') #=> "my_name"
 *  underscore('myName') #=> "my_name"
 *
 * @param {String} str
 * @return {String}
 */

function toSnake(m, p, offset, string) {
  return offset + p.length == string.length ? p.toLowerCase() : p.toLowerCase() + '_';
}

var notsnake_rxp = /((?:^[^A-Z]|[A-Z])+[^A-Z]*)/g;

function underscore(str) {
  return ('' + str).replace(notsnake_rxp, toSnake);
}

/**
 * Serialize string
 *
 * @example
 *   serialize('null') #=> null
 *   serialize('1.2') #=> 1.2
 *   serialize('true') #=> true
 * 
 * @param {String} str
 * @return {*}
 */

function serialize(str) {
  if (str == void 0) return null;
  str = '' + str;
  switch (str.toLowerCase().trim()) {
    case 'null':
      return null;
    case 'undefined':
      return undefined;
    case 'true':
      return true;
    case 'false':
      return false;
    case '':
      return '';
    default:
      return isNaN(val_n = Number(val)) ? val : val_n;
  }
}

/**
 * Strip quotes from a string (or do nothing if no quotes found)
 *
 * @param {String} str
 * @return {String}
 */

function stripQuotes(str) {
  var a = str.charCodeAt(0);
  var b = str.charCodeAt(str.length - 1);
  return a === b && (a === 0x22 || a === 0x27) ? str.slice(1, -1) : str;
}

/**
 * Replace double spaces with single space
 *
 * @param {String} str
 * @return {String}
 */

function squish(str) {
  return ('' + str).trim().replace(/\s+/g, ' ');
}

},{}],3:[function(require,module,exports){
"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.pi = pi;

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj["default"] = obj; return newObj; } }

var _coreUtils = require("./core/utils");

var _ = _interopRequireWildcard(_coreUtils);

function pi() {}

pi.utils = _;

},{"./core/utils":1}]},{},[3])


//# sourceMappingURL=build.js.map