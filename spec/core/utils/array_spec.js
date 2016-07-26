'use strict';
import * as _ from 'core/utils/array';

describe('array utils', () => {
  describe('#without', () => {
    it("returns the same array if no match", () => {
      expect(_.without(['a', 'b', 'd'], 'c')).toEqual(['a', 'b', 'd']);
    });

    it("returns array without matches", () => {
      expect(_.without(['a', 'b', 'c'], 'c')).toEqual(['a', 'b']);
    });

    it("returns array without several matches", () => {
      expect(_.without(['a', 'b', 'c'], 'c', 'a')).toEqual(['b']);
    });

    it("returns array without matches with duplicates", () => {
      expect(_.without(['c', 'c', 'c'], 'c', 'a')).toEqual([]);
    });
  });
});
