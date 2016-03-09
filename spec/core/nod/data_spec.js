'use strict';
import {Helpers as h} from 'spec/helpers';
import {Nod} from 'src/core/nod';
 
describe("NodData", () => {
  var nod;
  describe("#data", () => {
    it("get value", () => {
      nod = Nod.create(`
        <div data-id="1" data-user-name="john" data-all-valid="false">
        TEST
        </div>`
      );
      expect(nod.data('id')).toEqual(1);
      expect(nod.data('userName')).toEqual('john');
      expect(nod.data('user_name')).toEqual('john');
      expect(nod.data('user-name')).toEqual('john');
      expect(nod.data('all_valid')).toBe(false);
    });

    it("set value", () => {
      nod = Nod.create("<div>TEST</div>");
      nod.data('id', 1);
      expect(nod.data('id')).toEqual(1);
    });
  });
});
