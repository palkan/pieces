'use strict';
import {Helpers as h} from 'spec/helpers';
import {Compiler} from 'grammar/compiler';

window.grammar_test = {
  truthy(){
    return true;
  },
  echo(data){
    return data;
  },
  chain(){
    return {
      data: {
        to_s(){
          return 'data';        
        }
      }
    };
  },
  kill(num){
    return {killed: num};
  },
  log(level, msg){
    return {level, msg};
  }
};

describe("Compiler", () => {
  var res, f;

  describe("#compile", () => {
    it("parses simple args", () => {
      expect(Compiler.compile("123").call()).toEqual(123);
      expect(Compiler.compile("false").call()).toBeFalse();
      expect(Compiler.compile("'testo'").call()).toEqual('testo');
    });

    it("parses string with function calls", () => {
      f = Compiler.compile("grammar_test.kill(1).killed");
      expect(f.call()).toEqual(1);
    });

    it("parses string with special symbols", () => {
      res = Compiler.compile("grammar_test.log('info', 'image/png; charset=utf-8')").call();
      expect(res.level).toEqual('info');
      expect(res.msg).toEqual('image/png; charset=utf-8');
    });

    it("parses string with object arg", () => {
      res = Compiler.compile("grammar_test.echo(level: 'debug', code: 1)").call();
      expect(res.level).toEqual('debug');
      expect(res.code).toEqual(1);
    });

    it("parses simple operator", () => {
      expect(Compiler.compile("1+3").call()).toEqual(4);
      expect(Compiler.compile("100 / 10").call()).toEqual(10);
      expect(Compiler.compile("'testo' > 'testa'").call()).toBeTrue();
    });

    it("several operators", () => {
      expect(Compiler.compile("1+3/3").call()).toEqual(2);
      expect(Compiler.compile("100 / 10*2").call()).toEqual(20);
      expect(Compiler.compile("'testo' > 'test' + 'a'").call()).toBeTrue();
    });

    it("calls chained functions object", () => {
      f = Compiler.compile("grammar_test.chain().data.to_s()");
      expect(f.call()).toEqual('data');
    });

    it("parses simple logical expressions", () => {
      expect(Compiler.compile("true || false").call()).toBeTrue();
      expect(Compiler.compile("true && false").call()).toBeFalse();
    });

    it("parses logical expressions", () => {
      expect(Compiler.compile("(2 > 1 && 10 < 100) || 'false'").call()).toBeTrue();
      expect(Compiler.compile("(5 + 4 < 10) && (0 || false)").call()).toBeFalse();
    });

    it("calls conditional function", () => {
      window.grammar_test.flag = true;
      f = Compiler.compile("grammar_test.flag ? grammar_test.echo(flag: true) : 1");
      expect(f.call().flag).toBeTrue();

      window.grammar_test.flag = false;
      expect(f.call()).toEqual(1);
    });

    it("calls conditional function with operator", () => {
      window.grammar_test.flag = true
      f = Compiler.compile("grammar_test.chain().data.to_s() = 'data' ? true : false")
      expect(f.call()).toBeTrue();
    });

    it("calls conditional function with logical", () => {
      window.grammar_test.flag = true
      window.grammar_test.val = 10
      f = Compiler.compile("grammar_test.flag || grammar_test.val > 22 ? true : false")
      expect(f.call()).toBeTrue();
    });

    describe("with custom modifiers", () => {
      beforeEach(() => {
        Compiler.MODIFIERS['e'] = '_args[0]';
      });

      afterEach( () => {
        delete Compiler.MODIFIERS['e'];
      });

      it("recognizes custom modifier", () => {
        let e = { a: 1, b: 0, type: 'test' };
        f = Compiler.compile("e.type = 'test' ? e.a : e.b");
        expect(f.call(null, e)).toEqual(1);
        
        e.type = 'test2';
        expect(f.call(null, e)).toEqual(0);
      });
    });
  });
});
