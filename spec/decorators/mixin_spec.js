"use strict";

import {mixin} from 'src/decorators/mixin';

let ObjectMixin = {
  initialize($super) {
    $super()
    this._mix_object = true;
  }
}

class ClassMixin {
  initialize($super) {
    $super()
    this._mix_class = true;
  }

  dispose($super) {
    this._mix_class = false;
    $super()
  }

  get initialized() {
    return this._initialized;
  }

  set alive(val){
    return this._alive = val;
  }
}

function testClass(){
  return class {
    _initialized = false;
    _disposed = false;

    constructor() {
      this.initialize()
    }

    initialize() {
      this._initialized = true;
    }

    dispose() {
      this._disposed = true;
      this._initialized = false;
    }
  }
}

describe('mixin', () => {
  let obj;
  describe('mixin into class', () => {
    describe('ObjectMixin', () => {
      beforeEach(() => {
        let klass = testClass();
        mixin(ObjectMixin)(klass);
        obj = new klass();
      });

      it('calls super method', () => {
        expect(obj._initialized).toBe(true)
      });

      it('calls mixin method', () => {
        expect(obj._mix_object).toBe(true)
      });
    });

    describe('ClassMixin', () => {
      beforeEach(() => {
        let klass = testClass();
        mixin(ClassMixin)(klass);
        obj = new klass();
      });

      it('calls super method', () => {
        expect(obj._initialized).toBe(true)
      });

      it('calls mixin method', () => {
        expect(obj._mix_class).toBe(true)
      });

      it('adds getters', () => {
        expect(obj.initialized).toBe(true)
      });

      it('adds setters', () => {
        obj.alive = false;
        expect(obj._alive).toBe(false)
      });
    });

    describe('both ClassMixin and ObjectMixin', () => {
      beforeEach(() => {
        let klass = testClass();
        mixin(ObjectMixin)(klass);
        mixin(ClassMixin)(klass);
        obj = new klass();
      });

      it('calls super method', () => {
        expect(obj._initialized).toBe(true)
      });

      it('calls class mixin method', () => {
        expect(obj._mix_class).toBe(true)
      });

      it('calls obejct mixin method', () => {
        expect(obj._mix_object).toBe(true)
      });
    });
  });
});