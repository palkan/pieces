'use strict'

import * as _ from '../utils';

const datakey = Symbol('data');
const datacache = Symbol('datacache');

let dom_reader;

if(typeof DOMStringMap === "undefined"){

  let toDOMCase = function(str){
    return _.underscore(str).replace("_", "-");
  }

  dom_reader = function(el, key){
    return el.getAttribute(`data-${toDOMCase(key)}`);
  }

}else{

  dom_reader = function(el, key){
    return el.dataset[_.camelize(key)];
  }
}

class DataCache {
  constructor(nod){
    this._store = new Map();
    this.nod = nod;
  }

  remove(key){
    this._store.delete(key);
  }

  fetch(key){
    let val;
    if(val = this._store.get(key)) return val;

    val = dom_reader(this.nod.element, key);
    if(val === null) return;

    val = _.serialize(val);
    this._store.set(key, val);
    return val;
  }

  set(key, val){
    this._store.set(key, val);
  }
}

/**
* Add dataset manipulation functions to Nod
*/
export class NodData {
  /**
  * Get or set dataset value.
  * 
  * @param {String} key Data key (camelcase)
  * @param {*} [val] New value
  *
  * @return {*} Serialized data value
  *
  * @example
  *   // <span data-id="1" data-name="john">john</span>
  *   data('id'); #=> 1
  *   data('user_id') == data('userId') == data('user-id'); #=> 'john'
  * 
  *   // set value
  *   data('user_id', 1);
  */
  data(key, val){
    if(val === null) 
      this[datakey].remove(key);
    else if(val == void 0) 
      return this[datakey].fetch(key);
    else
      this[datakey].set(key, val);
    return this;
  }

  /** @private */
  get [datakey](){
    return this[datacache] || (this[datacache] = new DataCache(this));
  }
}
