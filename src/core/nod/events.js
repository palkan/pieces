'use strict'

import * as _ from '../utils';
import {mixin} from '../../decorators/mixin';
import {Event} from '../events/event';
import {EventDispatcher} from '../events/event_dispatcher';
import {Nod, matches} from '../nod';
import {delegate} from '../../decorators/delegate';

const targetSym = Symbol('target');

/**
* General wrapper for native events.
*/
@delegate({to: 'event'}, 'stopPropagation', 'stopImmediatePropagation',
  'preventDefault')
export class DOMEvent extends Event {
  constructor(event){
    // we must call super!
    super('null');
    // cleanup target
    this.target = null;
    
    this.event = event || window.event;
    this.type = this.event.type;
    this.origTarget = this.event.target;
    this.ctrlKey = this.event.ctrlKey;
    this.shiftKey = this.event.shiftKey;
    this.altKey = this.event.altKey;
    this.metaKey = this.event.metaKey;
    this.detail = this.event.detail;
    this.bubbles = this.event.bubbles;
  }

  get target(){
    return this[targetSym] || (this[targetSym] = Nod.create(this.origTarget));
  }

  set target(val){
    this[targetSym] = val;
  }

  cancel(){
    super.cancel();
    this.stopImmediatePropagation();
    this.preventDefault();
  }
}

/**
* Mouse events wrapper. Contains coordinates and wheel info.
*/
export class MouseEvent extends DOMEvent {
  constructor(event){
    super(event);
    
    this.button = this.event.button;

    if(this.pageX == void 0){
      this.pageX = this.event.clientX + document.body.scrollLeft + document.documentElement.scrollLeft; 
      this.pageY = this.event.clientY + document.body.scrollTop + document.documentElement.scrollTop;
    }

    if(this.offsetX == void 0){
      this.offsetX = this.event.layerX - this.origTarget.offsetLeft;
      this.offsetY = this.event.layerY - this.origTarget.offsetTop;
    }

    this.wheelDelta = this.event.wheelDelta;
    
    if(this.wheelDelta == void 0)
      this.wheelDelta = -this.event.detail * 40;
  }
}

/**
* Keyboard events wrapper. Contains keyCode and charCode.
*/
export class KeyEvent extends DOMEvent {
  constructor(event){
    super(event);  
    this.keyCode = this.event.keyCode || this.event.which;
    this.charCode = this.event.charCode;
  }
}

const mouse_regexp = /(click|mouse|contextmenu)/i;
const key_regexp = /(keyup|keydown|keypress)/i;
const selector_regexp = /^[\.#\[]/

let selector_filter = function(s, parent){
  if(selector_regexp.test(s)){
    return function(e){
      let parent = parent || document;
      let el = e.origTarget;
      
      if(matches.call(el, s)) return true; 
      if(el === parent) return false;

      while((el = el.parentNode) && el != parent){
        if(matches.call(el, s)){
          e.target = Nod.create(el)
          return true;
        }
      }

      return false;
    }
  }else{
    return function(e){
      return matches.call(e.origTarget, s);
    }
  }
}

const nelSym = Symbol('nel');

/**
* EventDispatcher extension with native events support.
*/
export class NodEvents {
  static buildEvent(e){
    if(mouse_regexp.test(e.type))
      return new MouseEvent(e);
    
    if(key_regexp.test(e.type))
      return new KeyEvent(e);
    
    return new DOMEvent(e)
  }

  listen(selector, event, callback, context){
    this.on(event, callback, context, selector_filter(selector, this.element));
  }

  addNativeListener(type){
    this.element.addEventListener(type, this.nativeEventListener);
  }

  removeNativeListener(type){
    this.element.removeEventListener(type, this.nativeEventListener);
  }

  get nativeEventListener(){
    return this[nelSym] || (this[nelSym] = ((e) => { this.trigger(NodEvents.buildEvent(e)) }));
  }

  get [mixin.override]() {
    return {
      storeListener(listener, $super) {
        if(!this.listeners[listener.type]){
          this.addNativeListener(listener.type);
        }          
        return $super(listener);
      },

      removeListenersType(type, $super){
        this.removeNativeListener(type);
        return $super(type);
      }
    }
  }
}
