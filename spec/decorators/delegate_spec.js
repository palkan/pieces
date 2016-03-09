"use strict";

import {delegate_property} from 'src/decorators/delegate';
import {delegate} from 'src/decorators/delegate';


class Delegatto{
  show(){
    this._visible = true;
  }

  hide(){
    this._visible = false;
  }

  get visible(){
    return this._visible || (this._visible = false);
  }

  set visible(val){
    this._visible = !!val;
  }

  get initialized(){
    return this._initialized;
  }

  set initialized(val){
    this._initialized = !!val;
  }

  set alive(val){
    this._alive = !!val;
  }

  get alive(){
    return this._alive;
  }
}

@delegate({to: 'element'}, 'show', 'hide')
@delegate_property({to: 'element'}, 'visible')
@delegate_property({to: 'element', setter: false}, 'initialized')
@delegate_property({to: 'element2', getter: false}, 'alive')
class TestClass{
  constructor(){
    this.element = new Delegatto();
    this.element2 = new Delegatto();
  }
}

describe('delegate', () => {
  let obj;

  beforeEach(() => {
    obj = new TestClass();
  });

  describe('delegate method', () => {
    it('calls method on delegator', () => {
      obj.show();
      expect(obj.visible).toBe(true)
      expect(obj.element.visible).toBe(true)
      obj.hide();
      expect(obj.visible).toBe(false)
      expect(obj.element.visible).toBe(false)
    });
  });

  describe('delegate property', () => {
    it('set property', () => {
      obj.visible = false;
      expect(obj.visible).toBe(false);
      expect(obj.element.visible).toBe(false);
      obj.element.initialized = true;
      expect(obj.element.initialized).toBe(true);
      obj.alive = false;
      expect(obj.element2.alive).toBe(false);
    });
  });
});