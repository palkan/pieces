'use strict';
import {Helpers as h} from 'spec/helpers';
import {Nod} from 'src/core/nod';

describe("Nod", () => {
  var testRoot, el, nod;

  beforeEach(() => {
    testRoot = h.testRoot();
  });

  afterEach(() => {
    testRoot.remove()
  });

  describe(".create", () => {
    it("creates Nod from Element", () => {
      el = document.createElement('div')
      nod = Nod.create(el);
      expect(nod.element.nodeName.toLowerCase()).toEqual('div');
      expect(Nod.create(el)).toEqual(nod);
    });

    it("create Nod only once", () => {
      nod = Nod.create(document.createElement('div'));
      let nod2 = Nod.create(nod);
      let nod3 = Nod.create(nod.element);
      expect(nod).toBe(nod2);
      expect(nod2).toBe(nod3);
      expect(nod3).toBe(nod);
    });

    it("returns null when no argument passed", () => {
      nod = Nod.create();
      expect(nod).toBeNull();
    });

    it("returns null when unknown argument type", () => {
      nod = Nod.create(100);
      expect(nod).toBeNull();
    });

    it("creates element from html", () => {
      nod = Nod.create('<a href="@test">Test</a>');
      expect(nod.element.nodeName.toLowerCase()).toEqual('a');
      expect(nod.attr('href')).toEqual('@test');
      expect(nod.text()).toEqual('Test');
    });
  });

  describe(".win", () => {
    it("loaded", (done) => {
      Nod.win.loaded().then(done);
    });
  });

  describe(".root", () => {
    it("ready", (done) => {
      Nod.root.ready().then(done);
    });
  });

  describe("#constructor", () => {
    it("creates new Nod", () => {
      el = document.createElement("div");
      nod = new Nod(el);
      expect(Nod.create(el)).toBe(nod);
    });

    it("throws if no element", () => {
      expect(() => new Nod({})).toThrow();
    });

    it("throws if element already initialized", () => {
      nod = Nod.create("<div></div>");
      expect(() => new Nod(nod.element)).toThrow();
    });
  });

  describe("#parent", () => {
    it("returns parent if no selector", () => {
      nod = Nod.create('<div><span>0</span></div>');
      let inner_nod = new Nod(nod.element.firstElementChild);
      expect(inner_nod.parent()).toBe(nod);
    });

    it("returns null if no parent", () => {
      nod = Nod.create("<div></div>");
      expect(nod.parent()).toBeNull();
    });

    it("returns parent by selector", () => {
      nod = Nod.create(`
        <div class="pi">
          <div class="a">
            <div class="b">
              <span>1</span>
            </div>
          </div>
        </div>`)
      testRoot.append(nod);

      let da = new Nod(nod.element.firstElementChild);
      let db = new Nod(da.element.firstElementChild);
      let sp = new Nod(db.element.firstElementChild);

      expect(sp.parent('.a')).toBe(da);
      expect(sp.parent('.b')).toBe(db);
      expect(sp.parent('.pi')).toBe(nod);
    });
  });

  describe("#text", () => {
    it("get text content", () => {
      nod = Nod.create("<div><span>Hello</span> <span>World!</span></div");
      expect(nod.text()).toEqual("Hello World!");
    });

    it("set text content", () => {
      nod = Nod.create("<div>Hello world!</div");
      nod.text("Goodbye, cruel world!");
      expect(nod.element.textContent).toEqual("Goodbye, cruel world!");
    });
  });

  describe("#html", () => {
    it("get html content", () => {
      nod = Nod.create("<div><span>Hello</span> <span>World!</span></div");
      expect(nod.html()).toEqual("<span>Hello</span> <span>World!</span>");
    });

    it("set html content", () => {
      nod = Nod.create("<div>Hello world!</div");
      nod.html("<a href='@test'>Test</a>")
      expect(nod.find('a').attr('href')).toEqual("@test");
    });
  });

  describe("#outerHtml", () => {
    it("get outer html content", () => {
      nod = Nod.create("<div><span>Hello</span> <span>World!</span></div");
      testRoot.append(nod);
      expect(nod.outerHtml()).toEqual("<div><span>Hello</span> <span>World!</span></div>");
    });
  });

  describe("#attr", () => {
    it("set attribute", () => {
      nod = Nod.create("<span>1</span>");
      nod.attr("id", "test");
      expect(nod.outerHtml()).toEqual(`<span id="test">1</span>`);
    });

    it("get attribute", () => {
      nod = Nod.create("<span id='test'>1</span>");
      expect(nod.attr('id')).toEqual('test');
    });

    it("remove attribute", () => {
      nod = Nod.create("<span id='test'>1</span>");
      expect(nod.attr('id', null).outerHtml()).toEqual('<span>1</span>');
    });
  });

  describe("#find", () => {
    it("find element", () => {
      nod = Nod.create(
        `<div>
          <a href="#">1</a>
          <span class="a">2</span>
          <span id="b">3</span>
          <div class="c"><span class="a">5</span></div>
        </div>`
      )
      testRoot.append(nod);

      expect(nod.find('a').text()).toEqual("1");
      expect(nod.find('.a').text()).toEqual("2");
      expect(nod.find('.c .a').text()).toEqual("5");
      expect(nod.find('#b').text()).toEqual("3");
    });
  });

  describe("#all", () => {
    it("find all elements", () => {
      nod = Nod.create(
        `<div>
          <a href="#">1</a>
          <span class="a">2</span>
          <span id="b">3</span>
          <div class="c"><span class="a">5</span></div>
        </div>`
      )
      testRoot.append(nod);

      let res = nod.all('span');
      expect(res.length).toEqual(3);
      expect(res[0] instanceof Element).toBe(true);
    });
  });

  describe("#each_in_cut", () => {
    it("returns only elements from cut", () => {
      nod = Nod.create(`
        <div>
          <div id="a" class="x">
            <div id="b" class="x"></div>
          </div>
          <div>
            <div>
              <div id="c" class="x"></div>
            </div>
          </div>
          <div id="d" class="x"></div>
          <div>
            <div id="e" class="x"></div>
            <div id="f" class="x">
              <div id="g" class="x"></div>
            </div>
          </div>
        </div>
      `);
      let res = '';
      for(let el of nod.each_in_cut('.x')){
        res += el.id;
      }
      expect(res).toEqual("adefc");
    });
  });
});
