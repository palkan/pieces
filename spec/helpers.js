'use strict'

import {Nod} from 'src/core/nod';
import * as _ from 'src/core/utils';

_.setLogLevel('debug');

/* Stub animation frame */
window.requestAnimationFrame = function(fun){ return fun(); }

let Helpers = {
  /** Creates div element and append it to body; returns element as Nod */
  testRoot: function(){
    let el = document.createElement('div');
    document.body.appendChild(el);
    return Nod.create(el);
  },

  mouseEvent: function(el, type, x = 0, y = 0){
    let ev = document.createEvent("MouseEvent");
    ev.initEvent(
      type,
      true,
      true
    );
    el.dispatchEvent(ev);
  },

  changeEvent: function(el){
    let ev = document.createEvent("HTMLEvents");
    ev.initEvent(
      'change',
      true,
      true
    );
    el.dispatchEvent(ev); 
  },

  submitEvent: function(el){
    let ev = document.createEvent("HTMLEvents");
    ev.initEvent(
      'submit',
      false,
      true
    );
    el.dispatchEvent(ev);
  },

  keyEvent: function(el, type, code, options = {}){
    if(typeof code === 'string') code = code.charCodeAt(0);

    let ev = document.createEvent("KeyboardEvent");
    event.initKeyEvent(
      type,                                                            
      true,                                                  
      true,                                                   
      null,  
      !!options['ctrl'],                                                     
      !!options['alt'],                                                   
      !!options['shift'],                                                  
      !!options['meta'],                                                 
      code,                                                                   
      String.fromCharCode(code)
     );                

    el.dispatchEvent(ev);
  },

  scrollEvent: function(el){
    let ev = document.createEvent("Event");
    ev.initEvent(
      'scroll',
      true,
      true
    )
    el.dispatchEvent(ev);
  },
  
  resizeEvent: function(){
    let ev = document.createEvent('UIEvents');
    ev.initUIEvent('resize', true, false, window, 0);
    window.dispatchEvent(ev);
  },

  click_on: function(el){
    Helpers.mouseEvent(el, "click");
  }
}

export {Helpers};
