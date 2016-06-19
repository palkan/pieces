'use strict';
import {Helpers as h} from 'spec/helpers';
import Net from 'src/core/net';

describe("Net", () => {
  // Restore default configuration
  beforeEach(() => {
    Net.configure(Net.config.defaults);
  });

  describe(".prepare_params",  () => {
    it("handles nested objects", () => {
      let data = {
        item: {
          tags: ['1','2'],
          id: 1,
          owner: {
            name: 'john',
            age: 10
          }
        }
      };
       
      let params = Net.prepare_params(data).map((p) => p.name);
      expect(params.length).toEqual(5);
      expect(params).toHaveMember(
        'item[tags][]',
        'item[id]',
        'item[owner][name]',
        'item[owner][age]'
      );
    });

    describe("Date", () => {
      it("converts to string by default", () => {
        let date = new Date();
        let params = Net.prepare_params({ date });

        expect(params[0].value).toEqual(date.toDateString());
      });

      it("converts to ISO", () => {
        Net.configure({ dateFormat: 'ISO' });

        let date = new Date();
        let params = Net.prepare_params({ date });

        expect(params[0].value).toEqual(date.toISOString());
      });

      it("converts to ms", () => {
        Net.configure({ dateFormat: 'ms' });

        let date = new Date();
        let params = Net.prepare_params({ date });

        expect(params[0].value).toEqual(date.getTime());
      });
    });
  });

  describe(".prepare_query", () => {
    it("creates query string from data", () => {
      let data = {id: 1, name: 'Ivan Fuckov'};
      expect(Net.prepare_query(data)).toEqual('id=1&name=Ivan%20Fuckov');
    });
  });

  describe(".request", () => {
    describe(".get", () => {
      it("sends request with query string", (done) => {
        Net.get('/test/echo?q=1').then((response) => {
          expect(response.data.q).toEqual('1');
          done()
        }).catch(done)
      });

      it("sends request with data", (done) => {
        Net.get('/test/echo', { q: 1 }).then((response) => {
          expect(response.data.q).toEqual('1');
          done()
        }).catch(done)
      });

      it("sends request with data and url query", (done) => {
        Net.get('/test/echo?a=test',{ q: 1 }).then((response) => {
          expect(response.data.q).toEqual('1');
          expect(response.data.a).toEqual('test');
          done()
        }).catch(done)
      });
    });


    ["post", "put", "patch", "delete"].forEach( (method) => {
      describe(`.${method}`, () => {
        it("sends request with data", (done) => {
          Net[method]('/test/echo', { item: { id: 1, user: { id: 123, name: 'john' } } })
          .then((response) => {
            expect(response.data[method].item.id).toEqual('1');
            expect(response.data[method].item.user.name).toEqual('john');
            done()
          }).catch(done)
        });
      });
    });
  });
});
