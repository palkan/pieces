'use strict'

import * as _ from '../utils';

export class NodStyles {
  /**
  * Get or set element style.
  * 
  * @param {String} name Style name
  * @param {*} [val] Style value
  *
  * @example
  *   // get style value
  *   style('display');
  * 
  *   // set style
  *   style('display', 'none');
  *
  *   // remove style
  *   style('display', null);
  */
  style(name, val){
    if(val === null) 
      this.element.style.removeProperty(name);
    else if(val == void 0) 
      return this.element.style[name];
    else
      this.element.style[name] = val;
    return this;
  }

  addClass(...classes){
    for(let c of classes) this.element.classList.add(c);
    return this;
  }

  removeClass(...classes){
    for(let c of classes) this.element.classList.remove(c);
    return this;
  }

  toggleClass(c){
    this.element.classList.toggle(c);
    return this;
  }

  hasClass(c){
    return this.element.classList.contains(c);
  }
}
