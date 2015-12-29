'use strict';
import {EventDispatcher} from '../../../src/core/events/event_dispatcher';
import {EventListener} from '../../../src/core/events/event_listener';

describe('EventDispatcher', () => {
  let subject;
  let spy;
  let event;

  beforeEach(() => {
    subject = new EventDispatcher();
    spy = jasmine.createSpy('listener');
  });

  describe('#on', () => {
    it('add event listener', () => {
      subject.on('event', spy);
      subject.trigger('event');
      expect(spy).toHaveBeenCalled();
    });

    it('with several event types', () => {
      subject.on('event1, event2', spy);
      subject.trigger('event1');
      expect(spy.calls.count()).toBe(1);
      subject.trigger('event2');
      expect(spy.calls.count()).toBe(2);
      subject.trigger('event3');
      expect(spy.calls.count()).toBe(2);
    });

    it('with custom context', () => {
      subject.name = 'a';
      let obj = { name: 'b' };
      let fun = function() { spy(this.name); };

      subject.on('event', fun, obj);
      subject.trigger('event');
      expect(spy).toHaveBeenCalledWith('b');
    });

    it('with filter', () => {
      subject.on('event', spy, null, (e) => { return e.good; });
      subject.trigger('event');
      expect(spy).not.toHaveBeenCalled();

      event = { type: 'event', good: true };
      subject.trigger(event);
      expect(spy).toHaveBeenCalled();
    });
  });

  describe('#one', () => {
    it('calls listener only once', () => {
      subject.one('event', spy);
      subject.trigger('event');
      subject.trigger('event');
      subject.trigger('event');
      expect(spy.calls.count()).toBe(1);
    });
  });

  describe('#off', () => {
    let spy2;

    beforeEach(() => {
      subject.on('event', spy);
    });

    it('removes specific event handler', () => {
      spy2 = jasmine.createSpy('new_listener');
      subject.on('event', spy2);
      subject.trigger('event');
      expect(spy).toHaveBeenCalled();
      expect(spy2).toHaveBeenCalled();
      subject.off('event', spy);
      subject.trigger('event');
      expect(spy.calls.count()).toBe(1);
      expect(spy2.calls.count()).toBe(2);
    });

    it('removes event handlers by type', () => {
      spy2 = jasmine.createSpy('new_listener');
      subject.on('event', spy2);
      subject.trigger('event');
      expect(spy).toHaveBeenCalled();
      expect(spy2).toHaveBeenCalled();
      subject.off('event');
      subject.trigger('event');
      expect(spy.calls.count()).toBe(1);
      expect(spy2.calls.count()).toBe(1);
    });

    it('removes all event handlers', () => {
      spy2 = jasmine.createSpy('new_listener');
      subject.on('event2', spy2);
      subject.trigger('event');
      subject.trigger('event2');
      expect(spy).toHaveBeenCalled();
      expect(spy2).toHaveBeenCalled();
      subject.off();
      subject.trigger('event');
      subject.trigger('event');
      expect(spy.calls.count()).toBe(1);
      expect(spy2.calls.count()).toBe(1);
    });

    it('removes context-specific event handlers', () => {
      let obj = { name: 'b' };
      subject.on('event', spy, obj);
      subject.trigger('event');
      expect(spy.calls.count()).toBe(2);
      subject.off('event', spy, obj);
      subject.trigger('event');
      expect(spy.calls.count()).toBe(3);
    });
  });

  describe('delegators', () => {
    const fakers = [];

    class FakeListener extends EventListener{
      static doFake() {
        fakers.forEach((faker) => { faker.dispatch({ type: 'fake' }); });
      }

      constructor(...args) {
        super(...args);
        fakers.push(this);
      }

      dispose() {
        super.dispose();
        fakers.splice(fakers.indexOf(this), 1);
      }
    }

    beforeEach(() => {
      EventDispatcher.registerTypeListener('fake', FakeListener);
    });

    afterEach(() => {
      EventDispatcher.unregisterTypeListener('fake', FakeListener);
    });

    it('create listeners for type', () => {
      subject.on('fake', spy);
      FakeListener.doFake();
      expect(spy).toHaveBeenCalled();
      subject.off('fake');
      FakeListener.doFake();
      expect(spy.calls.count()).toBe(1);
    });
  });
});
