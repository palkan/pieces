'use strict'

export function with_raf(id, fun){
  if(this[`__${id}_rid`]){
    window.cancelAnimationFrame(this[`__${id}_rid`]);
    delete this[`__${id}_rid`];
  }
  return this[`__${id}_rid`] = window.requestAnimationFrame(fun);
}
