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

let uniqueId = 100;

export function uid(pref = '') {
  return `${pref}${++uniqueId}`;
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
  let str = p1 || p2;
  return str ? str.toUpperCase() : '';
}

export function camelize(str) {
  return String(str).replace(/(?:^(\w)|_(\w))/g, toUp);
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

export function capitalize(str) {
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

const notsnakeRxp = /((?:^[^A-Z]|[A-Z])+[^A-Z]*)/g;

export function underscore(str) {
  return String(str).replace(notsnakeRxp, toSnake);
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

export function serialize(str) {
  if (str == void(0)) return null;
  str = String(str);
  switch (str.toLowerCase().trim()){
    case 'null': return null;
    case 'undefined': return undefined;
    case 'true': return true;
    case 'false': return false;
    case '': return '';
    default:
      let val = Number(str);
      return isNaN(val) ? str : val;
  }
}

/**
 * Strip quotes from a string (or do nothing if no quotes found)
 *
 * @param {String} str
 * @return {String}
 */

export function stripQuotes(str) {
  var a = str.charCodeAt(0);
  var b = str.charCodeAt(str.length - 1);
  return a === b && (a === 0x22 || a === 0x27) ?
    str.slice(1, -1) :
    str;
}

/**
 * Replace double spaces with single space
 *
 * @param {String} str
 * @return {String}
 */

export function squish(str) {
  return String(str).trim().replace(/\s+/g, ' ');
}
