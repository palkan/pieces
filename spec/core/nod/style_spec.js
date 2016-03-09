'use strict';
import {Helpers as h} from 'spec/helpers';
import {Nod} from 'src/core/nod';

describe("NodStyle", () => {
  var testRoot, el, nod;

  beforeEach(() => {
    testRoot = h.testRoot();
  });

  afterEach(() => {
    testRoot.remove()
  });

  describe("#style", () => {
    it("set style", () => {
      nod = Nod.create("<span>1</span>");
      nod.style("opacity", "0.9");
      expect(nod.outerHtml()).toMatch(/<span\s+style=\"opacity:\s*0\.9;\s*\"/);
    });

    it("get style", () => {
      nod = Nod.create("<span style='display: none;'>1</span>");
      expect(nod.style('display')).toEqual('none');
    });

    it("remove style", () => {
      nod = Nod.create("<span style='display: none; opacity: 0.9;'>1</span>");
      expect(nod.style('display', null).outerHtml()).toMatch(/<span\s+style=\"opacity:\s*0\.9;\s*\"/);
    });
  });

  describe("#addClass", () => {
    it("add one class", () => {
      nod = Nod.create("<span>1</span>");
      expect(nod.addClass('test').outerHtml()).toMatch(/<span\s+class=\"test\"/);
    });

    it("add several classes", () => {
      nod = Nod.create("<span>1</span>");
      expect(nod.addClass('bar', 'foo').outerHtml()).toMatch(/<span\s+class=\"bar\s+foo\"/);
    });
  });

  describe("#removeClass", () => {
    it("remove one class", () => {
      nod = Nod.create("<span class='test'>1</span>");
      expect(nod.removeClass('test').outerHtml()).toMatch(/<span\s+class=\"\"/);
    });

    it("remove several classes", () => {
      nod = Nod.create("<span class='foo bar'>1</span>");
      expect(nod.removeClass('bar', 'foo').outerHtml()).toMatch(/<span\s+class=\"\"/);
    });
  });

  describe("#toggleClass", () => {
    it("add class if no class", () => {
      nod = Nod.create("<span>1</span>");
      expect(nod.toggleClass('test').outerHtml()).toMatch(/<span\s+class=\"test\"/);
    });

    it("remove class if exists", () => {
      nod = Nod.create("<span class='foo bar'>1</span>");
      expect(nod.toggleClass('bar').outerHtml()).toMatch(/<span\s+class=\"foo\"/);
    });
  });

  describe("#hasClass", () => {
    it("return true if has class", () => {
      nod = Nod.create("<span class='test'>1</span>");
      expect(nod.hasClass('test')).toBe(true);
    });

    it("return false if no class", () => {
      nod = Nod.create("<span class='foo'>1</span>");
      expect(nod.hasClass('bar')).toBe(false);
    });
  });
});
