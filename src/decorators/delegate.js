'use strict'

export function delegate(options, ...methods){
  let to = options.to;
  if(!to) throw Error("Delegation target required");
  return (target) => { 
    for(let method of methods) {
      let descriptor = {
        configurable: true,
        writable: true,
        enumerable: false
      }

      descriptor.value = function(...args){
        return this[to][method](...args);
      };

      Object.defineProperty(target.prototype, method, descriptor);
    }
    return target;
  };
}

export function delegate_property(options, ...props){
  let to = options.to;
  if(!to) throw Error("Delegation target required");
  return (target) => { 
    for(let prop of props) {
      let descriptor = {
        configurable: true,
        enumerable: (options.getter != false)
      }

      if(options.setter !== false){
        descriptor.set = function(val){
          return this[to][prop] = val;
        };
      }

      if(options.getter !== false){
        descriptor.get = function(){
          return this[to][prop];
        };
      }

      Object.defineProperty(target.prototype, prop, descriptor);
    }
    return target;
  };
}
