'use strict';

import {Event} from 'src/core/events/event';

describe('Event', () => {
  let event;
  describe('constructor', () => {
    const target = { name: 'event target' };
    it('inits event from string', () => {
      event = new Event('smth', target);
      expect(event.target).toBe(target);
      expect(event.type).toEqual('smth');
      expect(event.bubbles).toBeTrue();
      expect(event.canceled).toBeFalse();
    });

    it('inits event from object', () => {
      event = new Event({ type: 'smth', kind: 'test' }, target);
      expect(event.target).toBe(target);
      expect(event.type).toEqual('smth');
      expect(event.bubbles).toBeTrue();
      expect(event.kind).toEqual('test');
    });

    it('sets bubbles', () => {
      event = new Event('smth', target, false);
      expect(event.bubbles).toBeFalse();
    });

    it('raises error if no type provided', () => {
      expect(() => { new Event(); }).toThrowError(Error);
    });
  });

  describe('#cancel', () => {
    it('set canceled to true', () => {
      event = new Event('smth');
      event.cancel();
      expect(event.canceled).toBeTrue();
    });
  });
});
