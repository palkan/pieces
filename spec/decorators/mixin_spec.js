"use strict";

import {mixin} from 'src/decorators/mixin';

let ObjectMixin = {
  [mixin.override]: {
    initialize($super) {
      $super()
      this._mix_object = true;
    }
  },

  [mixin.classMethods]: {
    mix() {
      return true;
    }
  }
}

class ClassMixin {
  get initialized() {
    return this._initialized;
  }

  set alive(val){
    return this._alive = val;
  }

  get [mixin.override]() {
    return {
      initialize($super) {
        $super()
        this._mix_class = true;
      },
      dispose($super) {
        this._mix_class = false;
        $super()
      }
    }
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
  let obj, klass;
  describe('mixin into class', () => {
    describe('ObjectMixin', () => {
      beforeEach(() => {
        klass = testClass();
        mixin(ObjectMixin)(klass);
        obj = new klass();
      });

      it('calls super method', () => {
        expect(obj._initialized).toBe(true)
      });

      it('calls mixin method', () => {
        expect(obj._mix_object).toBe(true)
      });

      it('calls mixin class method', () => {
        expect(klass.mix()).toBe(true)
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