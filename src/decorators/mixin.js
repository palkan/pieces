'use strict'

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
export function mixin(mod) {
  if(typeof mod === 'function'){
    mod = mod.prototype;
  }

  const instanceKeys = Reflect.ownKeys(mod);

  return (target) => {
    if(typeof target === 'function'){
      target = target.prototype;
    }

    for(let key of instanceKeys) {
      descriptor = Reflect.getOwnPropertyDescriptor(mod, key);

      const value = descriptor.value;

      if(typeof value === 'function'){
        descriptor.value = mixinSuper(value, target[key]);
      }

      Object.defineProperty(target, key, descriptor);
    }
  }
}
