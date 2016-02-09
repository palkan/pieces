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

export function extend(target, mixin, options = {}) {
  for (let key of Reflect.ownKeys(mixin)) {
    if (!options.overwrite && target.hasOwnProperty(key)) continue;

    if (
      options.only && (options.only.indexOf(key) === -1) ||
      options.except && (options.except.indexOf(key) > -1)
    ) continue;

    target[key] = mixin[key];
  }

  return target;
}

/**
* Add specified keys from source to target.
* Support filtering for nested objects.
*
*
* @example
*   extractTo({}, { a: 1, b: 2}, ['a']) #=> { a: 1 }
*   extractTo({}, { a: 1, b: { x: 2, z: 3 }}, [{ b: 'x' }]) #=> { b: { x: 2 } }
*
* @param {Object} target
* @param {Object} source
* @param {Array} params
*/
function extractTo(data, source, params) {
  if (!source) return;

  if (Array.isArray(source)) {
    if (!Array.isArray(data)) data = [];
    source.forEach((el) => data.push(extractTo({}, el, params)));
    return data;
  }else {
    if (typeof params === 'string') {
      if (source.hasOwnProperty(params)) data[params] = source[params];
      return data[params];
    } else if (Array.isArray(params)) {
      params.map((p) => extractTo(data, source, p));
    }else {
      for (let key of Reflect.ownKeys(params)) {
        data[key] = Array.isArray(source[key]) ? [] : {};
        extractTo(data[key], source[key], params[key]);
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
export function extract(source, params) {
  let data = {};
  extractTo(data, source, params);
  return data;
}

/**
* Clone anything: from primitives to objects, Date, RegExp, Element.
*
* @param {*} obj
* @return {*}
*/
export function clone(obj) {
  if (
    (obj == void 0) || typeof obj !== 'object'
    ) return obj;

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

  let newInstance = new obj.constructor();

  for (let key of Object.keys(obj)) {
    newInstance[key] = clone(obj[key]);
  }

  return newInstance;
}
