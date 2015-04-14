'use strict'
h = require 'pieces-core/test/helpers'

describe "Compiler", ->
  Compiler = pi.Compiler

  pi.app.grammar_test=
    kill: (num) ->
      killed: num
    alert: (msg) -> msg

    log: (level, msg) ->
      level: level, msg: msg

  class $r.PiCallTests extends $r.Base
    @set_resource 'call_tests'

  $r.Test = {}

  class $r.Test.Call extends $r.Base
    @set_resource 'calls'
    
  describe "compile_fun", ->
    R = $r.PiCallTests
    R2 = $r.Test.Call
    window._abc_ = 
      fun: -> true
      echo: (data) -> data
      chain: ->
        {data: {to_s: -> 'data'}}

    afterEach ->
      R.clear_all()

    it "parses simple arg", ->
      expect(Compiler.compile_fun("123").call()).to.eq 123
      expect(Compiler.compile_fun("false").call()).to.be.false
      expect(Compiler.compile_fun("'testo'").call()).to.eq 'testo'

    it "parses string with function calls", ->
      f = Compiler.compile_fun("app.grammar_test.kill(1).killed")
      expect(f.call()).to.eq 1

    it "parses string with special symbols", ->
      res = Compiler.compile_fun("app.grammar_test.log('info', 'image/png; charset=utf-8')").call()
      expect(res.level).to.eq 'info'
      expect(res.msg).to.eq 'image/png; charset=utf-8'

    it "parses string with object arg", ->
      res = Compiler.compile_fun("app.grammar_test.alert(level: 'debug', code: 1)").call()
      expect(res.level).to.eq 'debug'
      expect(res.code).to.eq 1

    it "parses simple operator", ->
      expect(Compiler.compile_fun("1+3").call()).to.eq 4
      expect(Compiler.compile_fun("100 / 10").call()).to.eq 10
      expect(Compiler.compile_fun("'testo' > 'testa'").call()).to.be.true

    it "calls global (window) object", ->
      f = Compiler.str_to_fun("_abc_.fun()")
      expect(f.call()).to.be.true

     it "calls with object arg", ->
      f = Compiler.str_to_fun("_abc_.echo(id: 1, hello: 'world', correct: true)")
      res = f.call()
      expect(res.correct).to.be.true
      expect(res.id).to.eq 1
      expect(res.hello).to.eq 'world'

    it "calls chained functions object", ->
      f = Compiler.str_to_fun("_abc_.chain().data.to_s()")
      expect(f.call()).to.be.eq 'data'

    it "calls resources function", ->
      R.build {id: 1, name: 'juju'}
      f = Compiler.str_to_fun("PiCallTests.get(1)")
      obj = f.call()
      expect(obj.name).to.be.eq 'juju'

    it "calls namespaced resources function", ->
      R2.build {id: 1, name: 'jojo'}
      f = Compiler.str_to_fun("Test.Call.get(1)")
      obj = f.call()
      expect(obj.name).to.be.eq 'jojo'

    it "calls conditional function", ->
      window._abc_.flag = true
      f = Compiler.str_to_fun("_abc_.flag ? _abc_.echo(flag: true) : 1")
      obj = f.call()
      expect(obj.flag).to.be.true
      window._abc_.flag = false
      obj = f.call()
      expect(obj).to.eq 1

    it "calls conditional function with operator", ->
      window._abc_.flag = true
      f = Compiler.str_to_fun("_abc_.chain().data.to_s() = 'data' ? true : false")
      obj = f.call()
      expect(obj).to.be.true

