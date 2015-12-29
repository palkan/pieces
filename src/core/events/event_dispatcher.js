'use strict';

import {Event} from './event';
import {EventListener} from './event_listener';

function _types(types) {
  if (typeof types === 'string')
    return types.split(/\,\s*/);
  else if (Array.isArray(types))
    return types;
  else
    return [null];
}

const TypeListener = {};

export class EventDispatcher {
  constructor() {
    this.listeners = {};
    this.listenersByKey = {};
  }

  // API functions

  /**
  * Register new listener class for type.
  *
  * @param {String} type
  * @param {Function} klass
  */
  static registerTypeListener(type, klass) {
    TypeListener[type] = klass;
  }

  static unregisterTypeListener(type) {
    delete TypeListener[type];
  }

  /**
  * Attach listener for event types `types`.
  * Optionally provide context and events filtering function.
  *
  * @param {String, Array} types
  * @param {Function} callback
  * @param {Object} [context]
  * @param {Function} [filter]
  */
  on(types, callback, context = null, filter = null) {
    for (let type of _types(types)) {
      this.addListener(type, callback, context, false, filter);
    }
  }

  /**
  * The same as `on` but attached listener would be triggered only once.
  *
  * @param {String, Array} types
  * @param {Function} callback
  * @param {Object} [context]
  * @param {Function} [filter]
  */
  one(types, callback, context = null, filter = null) {
    for (let type of _types(types)) {
      this.addListener(type, callback, context, true, filter);
    }
  }

  /**
  * Remove listeners.
  * It is possible to remove specific listener (using handler function),
  * listeners by event type or all listeners.
  *
  * @example
  *   // Remove all listeners for all events
  *   element.off()
  *
  *   // Remove all listeners of a type 'event'
  *   element.off('event')
  *
  * @param {String, Null} [event]
  * @param {Function, Null} [callback]
  * @param {Object, Null} [context]
  */
  off(types, callback, context, conditions) {
    for (let type of _types(types)) {
      this.removeListener(type, callback, context);
    }
  }

  /**
  * Trigger event
  *
  * @params {String, Object} event
  * @params [Object, Null] data data that will be passed with event as `event.data`
  * @params [Boolean] [bubbles]
  */
  trigger(event, data, bubbles = true) {
    if (!(event instanceof Event)) event = new Event(event, this, bubbles);
    event.data = data;
    event.currentTarget = this;

    if (this.listeners[event.type]) {
      for (let listener of this.listeners[event.type]) {
        listener.dispatch(event);
        if (event.canceled) break;
      }

      this.removeDisposedListeners();
    }

    if (!event.captured && event.bubbles) this.bubbleEvent(event);
  }

  // Internal functions

  bubbleEvent(_event) { /* overwrite this to implement custom bubbling */}

  addListener(type, callback, context, disposable, filter) {
    let listener = TypeListener[type] ?
      new TypeListener[type](type, callback, context, disposable, filter) :
      new EventListener(type, callback, context, disposable, filter);

    this.listeners[listener.type] = this.listeners[listener.type] || [];
    this.listeners[listener.type].push(listener);
    this.listenersByKey[listener.uid] = listener;
  }

  removeListener(type, callback, context) {
    if (!type) return this.removeAllListeners();

    if (!this.listeners[type]) return;

    if (!callback) return this.removeListenersType(type);

    let uid = `${type}:${callback._uid}`;

    if (context) uid += `:${context._uid}`;

    let listener = this.listenersByKey[uid];
    if (!listener) return;

    listener.dispose();
    delete this.listenersByKey[uid];
    this.removeListenerFromList(type, listener);
  }

  removeListenerFromList(type, listener) {
    if (this.listeners[type] && (this.listeners[type].indexOf(listener) > -1)) {
      this.listeners[type].splice(this.listeners[type].indexOf(listener), 1);
      if (!this.listeners[type].length) this.removeListenersType(type);
    }
  }

  removeDisposedListeners() {
    let listener;
    for (let key in this.listenersByKey) {
      listener = this.listenersByKey[key];
      if (listener.disposed) {
        this.removeListenerFromList(listener.type, listener);
        delete this.listenersByKey[key];
      }
    }
  }

  removeListenersType(type) {
    for (let listener of this.listeners[type]) {
      listener.dispose();
      delete this.listenersByKey[listener.key];
    }

    delete this.listeners[type];
  }

  removeAllListeners() {
    for (let type in this.listeners) {
      this.removeListenersType(type);
    }

    this.listeners = {};
    this.listenersByKey = {};
  }
}
