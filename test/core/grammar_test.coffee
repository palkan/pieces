'use strict'
h = require './helpers'

describe "pieces grammar and compiler", ->
  Compiler = pi.Compiler

  pi.app.grammar_test=
    kill: (num) ->
      killed: num
    alert: (msg) -> msg

    log: (level, msg) ->
      level: level, msg: msg

  describe "compiled functions", ->
    R = $r.create("pi_call_tests")
    window._abc_ = 
      fun: -> true
      echo: (data) -> data
      chain: ->
        {data: {to_s: -> 'data'}}

    afterEach ->
      R.clear_all()

    it "should parse simple arg", ->
      expect(Compiler.compile_fun("123").call()).to.eq 123
      expect(Compiler.compile_fun("false").call()).to.be.false
      expect(Compiler.compile_fun("'testo'").call()).to.eq 'testo'

    it "should parse string with function calls", ->
      f = Compiler.compile_fun("app.grammar_test.kill(1).killed")
      expect(f.call()).to.eq 1

    it "should parse string with special symbols", ->
      res = Compiler.compile_fun("app.grammar_test.log('info', 'image/png; charset=utf-8')").call()
      expect(res.level).to.eq 'info'
      expect(res.msg).to.eq 'image/png; charset=utf-8'

    it "should parse string with object arg", ->
      res = Compiler.compile_fun("app.grammar_test.alert(level: 'debug', code: 1)").call()
      expect(res.level).to.eq 'debug'
      expect(res.code).to.eq 1

    it "should call global (window) object", ->
      f = Compiler.str_to_fun("_abc_.fun()")
      expect(f.call()).to.be.true

     it "should call with object arg", ->
      f = Compiler.str_to_fun("_abc_.echo(id: 1, hello: 'world', correct: true)")
      res = f.call()
      expect(res.correct).to.be.true
      expect(res.id).to.eq 1
      expect(res.hello).to.eq 'world'

    it "should call chained functions object", ->
      f = Compiler.str_to_fun("_abc_.chain().data.to_s()")
      expect(f.call()).to.be.eq 'data'

    it "should call resources function", ->
      R.build {id: 1, name: 'juju'}
      f = Compiler.str_to_fun("PiCallTests.get(1)")
      obj = f.call()
      expect(obj.name).to.be.eq 'juju'

  describe "nod bind functions", ->
    Nod = pi.Nod

    root = h.test_cont(pi.Nod.body)

    before ->
      h.mock_raf()

    after ->
      h.unmock_raf()
      root.remove()