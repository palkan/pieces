(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
'use strict';

Object.defineProperty(exports, '__esModule', {
  value: true
});

function _interopExportWildcard(obj, defaults) { var newObj = defaults({}, obj); delete newObj['default']; return newObj; }

function _defaults(obj, defaults) { var keys = Object.getOwnPropertyNames(defaults); for (var i = 0; i < keys.length; i++) { var key = keys[i]; var value = Object.getOwnPropertyDescriptor(defaults, key); if (value && value.configurable && obj[key] === undefined) { Object.defineProperty(obj, key, value); } } return obj; }

var _string = require('./string');

_defaults(exports, _interopExportWildcard(_string, _defaults));

var _object = require('./object');

_defaults(exports, _interopExportWildcard(_object, _defaults));

},{"./object":2,"./string":3}],2:[function(require,module,exports){
'use strict';

/**
 * Extend object with another object.
 * By default it doesn't overwrite existing keys.
 * To overwrite existing keys set `overwrite` option to `true`.
 * 
 * You can whitelist/blacklist keys to inject using `only`/`except` option.
 *
 * @example 
 *  extend({ a: 1 }, { a: 2, b: 3 }) #=> { a: 1, b: 3 }
 *  extend({ a: 1 }, { a: 2, b: 3 }, { overwrite: true }) #=> { a: 2, b: 3 }
 *  extend({ a: 1 }, { a: 2, b: 3, c: 4 }, { except: ['c']}) #=> { a: 1, b: 3 }
 *  extend({ a: 1 }, { a: 2, b: 3, c: 4 }, { only: ['b']}) #=> { a: 1, b: 3 }
 *
 * @param {Object} target Object to extend
 * @param {Object} mixin Object to be mixed in
 * @param {Object} [options]
 * @return {Object}
 */

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.extend = extend;
exports.extract = extract;
exports.clone = clone;

function extend(target, mixin) {
  var options = arguments.length <= 2 || arguments[2] === undefined ? {} : arguments[2];
  var _iteratorNormalCompletion = true;
  var _didIteratorError = false;
  var _iteratorError = undefined;

  try {
    for (var _iterator = Object.keys(mixin)[Symbol.iterator](), _step; !(_iteratorNormalCompletion = (_step = _iterator.next()).done); _iteratorNormalCompletion = true) {
      var _key = _step.value;

      if (!options.overwrite && target.hasOwnProperty(_key)) continue;

      if (options.only && options.only.indexOf(_key) === -1 || options.except && options.except.indexOf(_key) > -1) continue;

      target[_key] = mixin[_key];
    }
  } catch (err) {
    _didIteratorError = true;
    _iteratorError = err;
  } finally {
    try {
      if (!_iteratorNormalCompletion && _iterator['return']) {
        _iterator['return']();
      }
    } finally {
      if (_didIteratorError) {
        throw _iteratorError;
      }
    }
  }

  return target;
}

/**
* Add specified keys from source to target.
* Support filtering for nested objects.
*
*
* @example
*   extract_to({}, { a: 1, b: 2}, ['a']) #=> { a: 1 }
*   extract_to({}, { a: 1, b: { x: 2, z: 3 }}, [{ b: 'x' }]) #=> { b: { x: 2 } }
*
* @param {Object} target
* @param {Object} source
* @param {Array} params
*/
function extract_to(data, source, params) {
  if (!source) return;

  if (Array.isArray(source)) {
    if (!Array.isArray(data)) data = [];
    source.forEach(function (el) {
      data.push(extract_to({}, el, params));
    });
    return data;
  } else {
    if (typeof params === 'string') {
      if (source.hasOwnProperty(params)) data[params] = source[params];
      return data[params];
    } else if (Array.isArray(params)) {
      params.forEach(function (p) {
        extract_to(data, source, p);
      });
    } else {
      var _iteratorNormalCompletion2 = true;
      var _didIteratorError2 = false;
      var _iteratorError2 = undefined;

      try {
        for (var _iterator2 = Object.keys(params)[Symbol.iterator](), _step2; !(_iteratorNormalCompletion2 = (_step2 = _iterator2.next()).done); _iteratorNormalCompletion2 = true) {
          var _key2 = _step2.value;

          if (!params.hasOwnProperty(_key2)) continue;
          Array.isArray(source[_key2]) ? data[_key2] = [] : data[_key2] = {};
          extract_to(data[_key2], source[_key2], params[_key2]);
        }
      } catch (err) {
        _didIteratorError2 = true;
        _iteratorError2 = err;
      } finally {
        try {
          if (!_iteratorNormalCompletion2 && _iterator2['return']) {
            _iterator2['return']();
          }
        } finally {
          if (_didIteratorError2) {
            throw _iteratorError2;
          }
        }
      }
    }
    return data;
  }
}

/**
* Create new object from source containing only specified keys.
* Support filtering for nested objects.
*
*
* @example
*   extract({ a: 1, b: 2}, ['a']) #=> { a: 1 }
*   extract({ a: 1, b: { x: 2, z: 3 }}, [{ b: 'x' }]) #=> { b: { x: 2 } }
*
* @param {Object} source
* @param {Array} params
* @return {Object}
*/

function extract(source, params) {
  var data = {};
  extract_to(data, source, params);
  return data;
}

/**
* Clone anything: from primitives to objects, Date, RegExp, Element.
*
* @param {*} obj
* @return {*}
*/

function clone(obj) {
  if (obj == void 0 || typeof obj != 'object') return obj;

  if (obj instanceof Date) return new Date(obj.getTime());

  if (obj instanceof RegExp) {
    var flags = '';
    if (obj.global) flags += 'g';
    if (obj.ignoreCase) flags += 'i';
    if (obj.multiline) flags += 'm';
    if (obj.sticky) flags += 'y';
    return new RegExp(obj.source, flags);
  }

  if (obj instanceof Element) return obj.cloneNode(true);

  if (typeof obj.clone === 'function') return obj.clone();

  newInstance = new obj.constructor();

  var _iteratorNormalCompletion3 = true;
  var _didIteratorError3 = false;
  var _iteratorError3 = undefined;

  try {
    for (var _iterator3 = Object.keys(obj)[Symbol.iterator](), _step3; !(_iteratorNormalCompletion3 = (_step3 = _iterator3.next()).done); _iteratorNormalCompletion3 = true) {
      key = _step3.value;

      newInstance[key] = clone(obj[key]);
    }
  } catch (err) {
    _didIteratorError3 = true;
    _iteratorError3 = err;
  } finally {
    try {
      if (!_iteratorNormalCompletion3 && _iterator3['return']) {
        _iterator3['return']();
      }
    } finally {
      if (_didIteratorError3) {
        throw _iteratorError3;
      }
    }
  }

  return newInstance;
}

},{}],3:[function(require,module,exports){
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
exports.strip_quotes = strip_quotes;
exports.squish = squish;
var _uniq_id = 100;

function uid() {
  var pref = arguments.length <= 0 || arguments[0] === undefined ? '' : arguments[0];

  return '' + pref + ++_uniq_id;
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

function toUp(m, p1, p2) {
  var str = p1 || p2;
  return str ? str.toUpperCase() : '';
}

function camelize(str) {
  return ('' + str).replace(/(?:^(\w)|_(\w))/g, toUp);
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
      var val = Number(str);
      return isNaN(val) ? str : val;
  }
}

/**
 * Strip quotes from a string (or do nothing if no quotes found)
 *
 * @param {String} str
 * @return {String}
 */

function strip_quotes(str) {
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

},{}],4:[function(require,module,exports){
'use strict';

Object.defineProperty(exports, '__esModule', {
  value: true
});
exports.pi = pi;

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj['default'] = obj; return newObj; } }

var _coreUtils = require('./core/utils');

var _ = _interopRequireWildcard(_coreUtils);

var _version = require('./version');

function pi() {}

pi.version = _version.VERSION;
pi.utils = _;

},{"./core/utils":1,"./version":5}],5:[function(require,module,exports){
'use strict';

Object.defineProperty(exports, '__esModule', {
  value: true
});
var VERSION = '0.5.0';
exports.VERSION = VERSION;

},{}]},{},[4])


//# sourceMappingURL=build.js.map