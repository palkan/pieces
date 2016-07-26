'use strict';
import {Helpers as h} from 'spec/helpers';
import {Nod} from 'core/nod';

describe("NodEvent", () => {
  var testRoot, el, nod, spy;

  beforeEach(() => {
    testRoot = h.testRoot();
    spy = jasmine.createSpy('listener');
    nod = Nod.create(`
      <div id='cont'>
        <button class='pi' data-pid='btn'>Button</button>
      </div>
    `);
    testRoot.append(nod);
    el = nod.find(".pi");
  });

  afterEach(() => {
    testRoot.remove()
  });

  it("add native events handlers", () => {
    el.on('click', spy);

    h.click_on(el.element);
    expect(spy.calls.count()).toBe(1);
  });

  it("work with several native events", () => {
    el.on("click, mouseover", spy);

    h.click_on(el.element);
    
    el.off("click");

    h.mouseEvent(el.element, "mouseover");
    h.click_on(el.element);

    expect(el.listeners.click).toBeUndefined();
    expect(el.listeners.mouseover.length).toEqual(1);
    expect(spy.calls.count()).toBe(2);
  });

  it("creates native event listener once by type", () => {
    spyOn(el, "addNativeListener");
    el.on("click, mouseover", spy);
    el.on("click", function(){});
    el.on("mouseover", function(){});

    expect(el.addNativeListener.calls.count()).toEqual(2);
  });

  it("remove all events on off", () => {
    el.on('click', spy);
    el.on('mousedown', spy);
    expect(el.listeners).toHaveMember('click','mousedown');

    el.off();
    expect(el.listeners).toEqual({});
  });

  it("doesn't call removed events", () => {
    el.on('click', spy);

    h.click_on(el.element);
    el.off();

    h.click_on(el.element);
    expect(spy.calls.count()).toBe(1);
  });

  it("remove native listener on off()", () => {
    el.on("click", (event) => { "hello" });
    el.on("click", spy);
    
    h.click_on(el.element);
    
    el.off();
    
    h.click_on(el.element);
    h.click_on(el.element);
    
    expect(el.listeners).toEqual({});
    expect(spy.calls.count()).toBe(1);
  });

  it("calls removeNativeListener on off()", () => {
    spyOn(el, "removeNativeListener");

    el.on("click", function(){});
    el.on("keypress", spy);
    el.off();

    expect(el.removeNativeListener.calls.count()).toEqual(2);
  });


  it("remove native listener on off(event)", () => {
    el.on("click", (event) => { "hello" });
    el.on("click", spy);
    
    h.click_on(el.element);
    
    el.off('click');
    
    h.click_on(el.element);
    h.click_on(el.element);
    
    expect(el.listeners.click).toBeUndefined();
    expect(spy.calls.count()).toBe(1);
  });


  it("remove native listener on off(event,callback,context)", () => {
    let dummy = { spy: jasmine.createSpy('dummy_listener') };

    el.on("click", dummy.spy, dummy);

    h.click_on(el.element);
    
    el.off('click', dummy.spy, dummy);
    
    h.click_on(el.element);
    h.click_on(el.element);

    expect(el.listeners.click).toBeUndefined();
    expect(dummy.spy.calls.count()).toEqual(1);
  });

  it("call once if one(event)", () => {
    let dummy = { spy: jasmine.createSpy('dummy_listener') };

    el.one("click", dummy.spy, dummy);

    h.click_on(el.element);
    h.click_on(el.element);
    h.click_on(el.element);

    expect(dummy.spy.calls.count()).toEqual(1);
  });

  it("remove native listener after event if one(event)", () => { 
    let dummy = { spy: jasmine.createSpy('dummy_listener') };

    el.one("click", dummy.spy, dummy);

    h.click_on(el.element);
    h.click_on(el.element);
    h.click_on(el.element);

    expect(el.listeners.click).toBeUndefined();
    expect(dummy.spy.calls.count()).toEqual(1);
  });

  it("call removeNativeListener if one(event)", () => { 
    spyOn(el, "removeNativeListener");
    
    let dummy = { spy: jasmine.createSpy('dummy_listener') };

    el.one("click", dummy.spy, dummy);

    h.click_on(el.element);
    h.click_on(el.element);

    expect(el.removeNativeListener.calls.count()).toEqual(1);
  });

  it("bubbles", () => {
    nod.on("click", spy);

    h.click_on(el.element);
    expect(spy.calls.count()).toEqual(1);
  });

  it("cancels native event", () => {
    nod.on("click", spy);
    el.on("click", (e) => { e.cancel(); });

    h.click_on(el.element);
    expect(spy.calls.count()).toEqual(0);
  });

  describe("#listen", () => {
    it("works with class", () => {
      nod.listen(".pi", "click", spy);

      h.click_on(el.element);
      expect(spy.calls.count()).toEqual(1);
    });

    it("works with tags", () => {
      nod.listen("button", "click", spy);

      h.click_on(el.element);
      expect(spy.calls.count()).toEqual(1);
    });

    it("works with attr selector", () => {
      nod.listen("[data-pid=\"btn\"]", "click", spy);

      h.click_on(el.element);
      expect(spy.calls.count()).toEqual(1);
    });

    it("event contains target", (done) => {
      nod.listen(".pi", "click", (e) => {
        expect(e.target).toBe(el);
        done();
      });

      h.click_on(el.element);
    });
  });
});
