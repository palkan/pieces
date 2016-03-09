'use strict';
import {Helpers as h} from 'spec/helpers';
import {Nod} from 'src/core/nod';

describe("NodGeometry", () => {
  var testRoot, el, nod;

  beforeEach(() => {
    testRoot = h.testRoot();
    testRoot.style("position", "fixed");
    testRoot.style("margin", "0");
    testRoot.style("padding", "0");
    testRoot.top = 0;
    testRoot.left = 0;

    nod = Nod.create(`
      <div style="background: yellow; position: absolute; top: 120px; left: 34px; margin: 0; padding: 0; display: block; width: 100px; height: 120px;">
        <div style="background: red; position: absolute; top: 10px; left: 20px; margin: 0; padding: 0; display: block; width: 10px; height: 14px;">1</div>
      </div>
    `);
    testRoot.append(nod);
    el = nod.find("div");
  });

  afterEach(() => {
    testRoot.remove()
  });

  describe("#x", () => {
    it("return x position", () => {
      expect(el.x).toEqual(54);
    });
  });

  describe("#y", () => {
    it("return y position", () => {
      expect(el.y).toEqual(130);
    });
  });

  describe("#position", () => {
    it("return x and y", () => {
      let res = el.position;
      expect(res.x).toEqual(54);
      expect(res.y).toEqual(130);
    });
  });

  describe("#offset", () => {
    it("return local x and y", () => {
      let res = el.offset;
      expect(res.x).toEqual(20);
      expect(res.y).toEqual(10);
    });
  });

  describe("#width", () => {
    it("returns width", () => {
      expect(nod.width).toEqual(100);
      expect(el.width).toEqual(10);
    });

    it("returns width with borders", () => {
      nod.style("border", "1px solid black");
      expect(nod.width).toEqual(102);
    });

    it("sets width", () => {
      nod.width = 130;
      expect(nod.width).toEqual(130);
    });
  });

  describe("#height", () => {
    it("returns height", () => {
      expect(nod.height).toEqual(120);
      expect(el.height).toEqual(14);
    });

    it("returns height with borders", () => {
      nod.style("border", "1px solid black");
      expect(nod.height).toEqual(122);
    });

    it("sets height", () => {
      nod.height = 100;
      expect(nod.height).toEqual(100);
    });
  });

  describe("#top", () => {
    it("returns top offset", () => {
      expect(el.top).toEqual(10);
    });

    it("sets top offset", () => {
      el.top = 20;
      expect(el.top).toEqual(20);
    });
  });

  describe("#left", () => {
    it("returns left offset", () => {
      expect(el.left).toEqual(20);
    });

    it("sets left offset", () => {
      el.left = 20;
      expect(el.left).toEqual(20);
    });
  });

  describe("#clientWidth", () => {
    it("", ()=> {
      expect(el.clientWidth).toEqual(10);
    });
  })

  describe("#clientHeight", () => {
    it("", ()=> {
      expect(el.clientHeight).toEqual(14);
    });
  })

  describe("scrolling", () => {
    beforeEach( () => {
      nod.height = 30;
      nod.width = 26;
      nod.style("overflow", "scroll");
      el.style("position", "relative");
      el.style("top", null);
      el.style("left", null);
      el.height = 50;
      el.width = 60;
    });

    describe("#scrollHeight", () => {
      it("", () => {
        expect(el.scrollHeight).toEqual(50);
      });
    });

    describe("#scrollWidth", () => {
      it("", () => {
        expect(el.scrollWidth).toEqual(60);
      });
    });

    describe("#scrollTop", () => {
      it("", () => {
        nod.scrollTop = 10;
        expect(nod.scrollTop).toEqual(10);
      });
    });

    describe("#scrollLeft", () => {
      it("", () => {
        nod.scrollLeft = 10;
        expect(nod.scrollLeft).toEqual(10);
      });
    })
  });
});
