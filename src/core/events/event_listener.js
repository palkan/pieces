'use strict';

import * as _ from '../utils';

/**
* Base event listener class
*/
export class EventListener {
  constructor(type, handler, context = null, disposable = false, filter = null) {
    this.type = type;
    this.filter = filter;
    this.disposable = disposable;

    // add uid to function to recognize it later
    if (!handler._uid) handler._uid = _.uid('func');

    this.handler = handler;
    this.uid = `${this.type}:${this.handler._uid}`;

    if (context) {
      if (!context._uid) context._uid = _.uid('obj');
      this.uid += `:${context._uid}`;
    }

    this.context = context;
  }

  dispatch(event) {
    if (this.disposed || (this.filter && !this.filter(event))) return;

    event.captured = this.handler.call(this.context, event) !== false;
    if (this.disposable) this.dispose();
  }

  dispose() {
    this.handler = this.context = this.filter = null;
    this.disposed = true;
  }
}
