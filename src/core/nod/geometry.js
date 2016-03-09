'use strict'

import * as _ from '../utils';
import {delegate_property} from '../../decorators/delegate';
import {with_raf} from './with_raf';

@delegate_property(
  {to: 'element', setter: false},
  'scrollLeft', 'scrollTop', 'clientWidth', 'clientHeight',
  'scrollWidth', 'scrollTop', 'scrollLeft', 'scrollHeight'
)
class NodGeometry {
  /**
  * Return element's global left coordinate
  */
  get x(){
    let offset = this.element.offsetLeft;
    let node = this.element;
    while(node = node.offsetParent)
      offset += node.offsetLeft;
    return offset;
  }

  /**
  * Return element's global top coordinate
  */
  get y(){
    let offset = this.element.offsetTop;
    let node = this.element;
    while(node = node.offsetParent) 
      offset += node.offsetTop;
    return offset;
  }

  /**
  * Get element local offset
  *
  * @return {Object} {x: left, y: right}
  */
  get offset(){
    return { x: this.element.offsetLeft, y: this.element.offsetTop };
  }

  /**
  * Get element global position
  */
  get position(){
    return { x: this.x, y: this.y };
  }
}

for(let prop of ['width', 'height', 'top', 'left']){
  Object.defineProperty(NodGeometry.prototype, prop,
  {
    get(){
      return this.element[`offset${_.capitalize(prop)}`];
    },
    set(val){
      this.style(prop, `${val}px`)
    }
  });
}

for(let prop of ['scrollLeft', 'scrollTop']){
  Object.defineProperty(NodGeometry.prototype, prop,
  {
    set(val){
      return with_raf.call(this, prop, () => { this.element[prop] = val; });
    }
  });
}

export {NodGeometry};
