'use strict'

import * as _ from '../core/utils';

function mixinSuper(fun, $super){
  return function(...args){
    if($super) args.push($super.bind(this));
    fun.apply(this, args);
  };
}

/**
* Create decorator to mixin object or class.
* 
* Every mixin function receives additional argument – $super,
* – which call previously defined function (or no-op if no such function).
* 
* @example
*   ...
*
* @return {Function}
*/
function mixin(mod) {
  if(typeof mod === 'function'){
    mod = mod.prototype;
  }

  const instanceKeys = _.without(
    Reflect.ownKeys(mod),
    'constructor', mixin.override, mixin.classMethods
  );

  const superKeys = mod[mixin.override] || [];
  const staticKeys = mod[mixin.classMethods] || [];

  return (target) => {
    for(let key of instanceKeys) {
      let descriptor = Reflect.getOwnPropertyDescriptor(mod, key);
      Object.defineProperty(target.prototype, key, descriptor);
    }

    for(let key in superKeys) {
      let descriptor = {
        configurable: true,
        writable: true,
        enumerable: false
      }
      descriptor.value = mixinSuper(mod[mixin.override][key], target.prototype[key]);
      Object.defineProperty(target.prototype, key, descriptor);
    }

    for(let key in staticKeys) {
      let descriptor = {
        configurable: true,
        writable: true,
        enumerable: false
      }
      descriptor.value = mod[mixin.classMethods][key];
      Object.defineProperty(target, key, descriptor);
    }
  }
}

mixin.override = Symbol('override');
mixin.classMethods = Symbol('classMethods');
export {mixin};
