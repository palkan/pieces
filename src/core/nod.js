'use strict';

import {mixin} from '../decorators/mixin';
import {EventDispatcher} from './events/event_dispatcher';
import {NodEvents} from './nod/events';
import {NodStyles} from './nod/styles';
import {NodGeometry} from './nod/geometry';
import {NodData} from './nod/data';
import {with_raf} from './nod/with_raf';
import * as _ from './utils';

const nodCache = new WeakMap();

function _element(node){
  switch(true){
    case node instanceof Nod:
      return node.element;
    case (node instanceof Element):
      return node;
    case (typeof node === 'string'):
      return Nod.fragmentFromString(node);
    default:
      return null;
  }
}

let proto = Element.prototype;

export let matches = proto.matches ||
         proto.matchesSelector ||
         proto.mozMatchesSelector ||
         proto.msMatchesSelector ||
         proto.oMatchesSelector ||
         proto.webkitMatchesSelector;

/**
* DOM element wrapper.
*/
@mixin(NodData)
@mixin(NodStyles)
@mixin(NodGeometry)
@mixin(NodEvents)
@mixin(EventDispatcher)
class Nod {
  /**
  * Create new Nod or return existing.
  *
  * @param {Nod, Element, String} node
  *
  * @example
  *
  *  // create Nod from HTMLElement
  *  let el = document.createElement('div');
  *  let nod = Nod.create(el);
  *
  *  // `Nod.create` is idemponent
  *  nod === Nod.create(el) #=> true
  *
  *  // create Nod from string
  *  let nod = Nod.create('<a href="#">Link</a>');
  *  nod.element.tagName #=> 'A'
  *
  *  nod === Nod.create(nod) #=> true 
  */
  static create(node){
    let nod;
    switch(true){
      case node instanceof Nod:
        return node;
      case !!(nod = nodCache.get(node)):
        return nod;
      case (typeof node === 'string'):
        return Nod.fromString(node);
      case (node instanceof Element):
        return new Nod(node);
      default:
        return null;
    }
  }

  /**
  * Create DocumentFragment from html string.
  *
  * @param {String} html
  */
  static fragmentFromString(html){
    let temp = document.createElement('div');
    temp.innerHTML = html.trim();
    let f = document.createDocumentFragment();
    while(temp.firstChild){
      f.appendChild(temp.firstChild);
    }
    return f;
  }

  /**
  * @private
  */
  static fromString(html){
    let temp = Nod.fragmentFromString(html);
    let el = temp.firstChild;
    temp.removeChild(el);
    return new Nod(el);
  }

  static get win(){
    return Win.instance;
  }

  static get root(){
    return Root.instance;
  }

  constructor(element){
    if(!element || !((element instanceof Element) || (element === window))){
      throw Error("Nod constructor requires HTMLElement");
    }

    if(nodCache.get(element)) throw Error("Element already has associated Nod"); 

    this.element = element;
    nodCache.set(element, this);
  }

  /**
  * If no arguments provided returns nod's element parent (as Nod).
  * 
  * If selector is provided then returns the first matching ancestor (as Nod)
  * 
  * @param {String} [selector]
  */
  parent(selector){
    if(!selector){
      return Nod.create(this.element.parentNode);
    }else{
      let p = this.element;
      while((p = p.parentNode) && (p != document)){
        if(matches.call(p, selector)){
          return Nod.create(p);
        }
      }
      return null;
    }
  }

  wrap(tag = 'div'){
    let wrapper = document.createElement(tag);
    this.element.parentNode.insertBefore(wrapper.element, this.element);
    wrapper.appendChild(this.element);
    return Nod.create(wrapper);
  }

  /**
  * Prepend node to element children with HTMLElement or HTML string
  *
  * @param {String, HTMLElement} node
  */
  prepend(node){ 
    let el = _element(node);
    if(this.element.childElementCount){
      this.element.insertBefore(el, this.element.firstChild);
    }else this.element.appendChild(el);
    return this;
  }

  /**
  * Append node to element children with HTMLElement or HTML string
  *
  * @param {String, HTMLElement} node
  */
  append(node){ 
    let el = _element(node);
    this.element.appendChild(el);
    return this;
  }

  /**
  * Insert node before element within element's parent children
  *
  * @param {String, HTMLElement} node
  */
  insertBefore(node){
    if(!this.element.parentNode) throw Error('Element has no parent');
    let el = _element(node);
    this.element.parentNode.insertBefore(el, this.element);
    return this;
  }

  /**
  * Insert node after element within element's parent children
  *
  * @param {String, HTMLElement} node
  */
  insertAfter(node){
    if(!this.element.parentNode) throw Error('Element has no parent');
    let el = _element(node);
    if(this.element.parentNode.childElementCount > 1){
      this.element.parentNode.insertBefore(el, this.element.nextSibling);
    }else this.element.parentNode.append(el);
    return this;
  }

  /** Remove element from parent node */
  detach(){
    if(this.element.parentNode) this.element.parentNode.removeChild(this.element);
    return this;
  }

  /** Detach all children */
  detach_children(){
    while(this.element.firstChild){
      this.element.removeChild(this.element.firstChild);
    }
    return this;
  }

  /** 
  * Remove all children by calling `remove` on them (when possible) 
  * This method should be used if there are Nods among descendants of the elements. 
  */
  remove_children(){
    while(this.element.firstElementChild){
      Nod.create(this.element.firstElementChild).remove();
    }
    return this;
  }

  /**
  * Detach node, remove children and dispose.
  */
  remove(){
    this.detach();
    this.remove_children();
    this.dispose();
  }

  /** Cleanup Nod cache */
  dispose(){
    if(this.disposed) return;
    nodCache.delete(this.element);
    this.disposed = true;
  }

  /** Get or set element text content. */
  text(val){
    if(val == void 0) return this.element.textContent;
    this.element.textContent = val;
    return this;
  }

  /** Get or set element HTML content. */
  html(val){
    if(val == void 0) return this.element.innerHTML;
    this.remove_children();
    this.element.innerHTML = val;
    return this;
  }

  /** Get element's outer HTML */
  outerHtml(){
    return this.element.outerHTML;
  }

  /**
  * Get or set element attribute.
  * 
  * @param {String} prop Property nane
  * @param {*} [val] Property value
  *
  * @example
  *   // get property
  *   attr('href');
  * 
  *   // set property
  *   attr('name', 'id');
  *
  *   // remove property
  *   attr('name', null);
  */
  attr(prop, val){
    if(val === null) 
      this.element.removeAttribute(prop);
    else if(val == void 0) 
      return this.element.getAttribute(prop);
    else
      this.element.setAttribute(prop, val);
    return this;
  }

  /** `querySelector` wrapper */
  find(selector){
    return Nod.create(this.element.querySelector(selector));
  }

  /** Return all matching Elements without casting to Nod */ 
  all(selector){
    return this.element.querySelectorAll(selector);
  }

  /** TODO */
  *each_in_cut(selector){
    let el = this.element.firstElementChild;
    const rest = [];

    while(el){
      if(matches.call(el, selector))
        yield el;
      else
        el.firstElementChild && rest.unshift(el.firstElementChild);
      el = el.nextElementSibling || rest.shift();
    }     
  }
}

export {Nod};

const instanceSym = Symbol('instance');

// Singleton class for document.documentElement
export class Root extends Nod {
  static get instance(){
    return Root[instanceSym] || (Root[instanceSym] = new Root());
  }

  constructor(){
    if(Root[instanceSym]) throw "Root is already defined!";
    super(document.documentElement);
    Root[instanceSym] = this;
    this.initialize();
  }

  /* @private */
  initialize(){
    if(document.readyState === 'interactive' || document.readyState === 'complete'){
      return this.ready_promise = Promise.resolve();
    }

    this.ready_promise = new Promise(
      (resolve) => {
        document.addEventListener('DOMContentLoaded', () => {
          _.info("DOMContentLoaded");
          resolve();
        });
      }
    );
  }

  /**
  * Return Promise which is resolved when DOM content is loaded
  */
  ready(){
    return this.ready_promise;
  }

  get scrollTop(){
    return this.element.scrollTop || document.body.scrollTop;
  }
  
  get scrollLeft(){
    return this.element.scrollLeft || document.body.scrollLeft;
  }

  get height(){
    return window.innerHeight || this.element.clientHeight;
  }

  get width(){
    return window.innerWidth || this.element.clientWidth;
  }
}

// Singleton class for window
export class Win extends Nod{
  static get instance(){
    return Win[instanceSym] || (Win[instanceSym] = new Win());
  }

  constructor(){
    if(Win[instanceSym]) throw "Win is already defined!";
    super(window);
    Win[instanceSym] = this;
    this.initialize();
  }

  /* @private */
  initialize(){
    if(document.readyState === 'complete'){
      return this.loaded_promise = Promise.resolve();
    }

    this.loaded_promise = new Promise(
      (resolve) => {
        window.addEventListener('load', (e) => {
          _.info("Loaded");
          resolve();
        });
      }
    );
  }

  /**
  * Return Promise which is resolved when window is fully loaded
  */
  loaded(){
    return this.loaded_promise;
  }

  set scrollY(y){
    let x = this.scrollLeft;
    return with_raf.call(this, 'scrollY', () => { this.element.scrollTo(x, y); });
  }

  set scrollX(x){
    let y = this.scrollTop;
    return with_raf.call(this, 'scrollY', () => { this.element.scrollTo(x, y); });
  }

  get width(){
    return this.element.innerWidth;
  }

  get height(){
    return this.element.innerHeight;
  }   

  get x(){ return 0; }

  get y(){ return 0; }
}
