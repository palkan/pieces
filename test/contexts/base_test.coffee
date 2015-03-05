'use strict'
h = require 'pi/test/helpers'

describe "Context", ->
  ctx = null

  a = new pi.controllers.TestContext()
  b = new pi.controllers.TestContext()

  afterEach ->
    a.clear()
    b.clear()

  describe "OneForAll", ->
    beforeEach ->
      ctx = new pi.controllers.Context(strategy: 'one_for_all', default: 'a')
      ctx.add_context a, as: 'a'
      ctx.add_context b, as: 'b'
      
    it "load default context", (done) ->
      ctx.load().then(
        ->
          expect(ctx.context).to.eq a
          done()
      ).catch(done)

    it "switch another context", (done) ->
      ctx.load().then(
        ->
          ctx.switch_to('b', 'test')
      ).then(
        ->
          expect(ctx.context).to.eq b
          expect(b.state).to.eq 'loaded'
          expect(b.data.params).to.eq 'test'
          expect(a.state).to.eq 'unloaded'
          done()
      ).catch(done)

     it "switch back and forth", (done) ->
      ctx.load().then(
        ->
          ctx.switch_to('b', 'test')
      ).then(
        ->
          expect(ctx.context).to.eq b
          expect(b.state).to.eq 'loaded'
          ctx.switch_back()
      ).then(
        ->
          expect(ctx.context).to.eq a
          expect(b.state).to.eq 'unloaded'
          expect(a.state).to.eq 'loaded'
          ctx.switch_forward()
      ).then(
        ->
          expect(ctx.context).to.eq b
          expect(a.state).to.eq 'unloaded'
          expect(b.state).to.eq 'loaded'
          ctx.switch_forward()
      ).then(
        -> 
          expect(ctx.context).to.eq b
          expect(a.state).to.eq 'unloaded'
          expect(b.state).to.eq 'loaded'
          done()
      ).catch(done)


  describe "OneByOne", ->
    c = new pi.controllers.SlowContext()

    afterEach ->
      c.clear()

    beforeEach ->
      ctx = new pi.controllers.Context(strategy: 'one_by_one', default: 'a')
      ctx.add_context a, as: 'a'
      ctx.add_context b, as: 'b'
      ctx.add_context c, as: 'c'
      
    it "load default context", (done) ->
      ctx.load().then(
        ->
          expect(ctx.context).to.eq a
          done()
      ).catch(done)

    it "switch up and down, back and forth", (done) ->
      ctx.load().then(
        ->
          ctx.switch_up('b', 'test')
      ).then(
        ->
          expect(ctx.context).to.eq b
          expect(b.state).to.eq 'loaded'
          expect(b.data.params).to.eq 'test'
          expect(a.state).to.eq 'deactivated'
          ctx.switch_up('c', 'cest')
      ).then(
        ->
          expect(ctx.context).to.eq c
          expect(b.state).to.eq 'deactivated'
          expect(c.data.params).to.eq 'cest'
          expect(c.state).to.eq 'loaded'
          ctx.switch_back()
      ).then(
        ->
          expect(ctx.context).to.eq b
          expect(b.state).to.eq 'activated'
          expect(c.state).to.eq 'unloaded'
          ctx.switch_back()
      ).then(
        ->
          expect(ctx.context).to.eq a
          expect(b.state).to.eq 'unloaded'
          expect(a.state).to.eq 'activated'
          ctx.switch_forward()
      ).then(
        ->
          expect(ctx.context).to.eq b
          expect(b.state).to.eq 'loaded'
          expect(a.state).to.eq 'deactivated'
          done()
      ).catch(done)

  describe "AllForOne", ->
    c = new pi.controllers.SlowContext()

    afterEach ->
      c.clear()

    beforeEach ->
      ctx = new pi.controllers.Context(strategy: 'all_for_one')
      ctx.add_context a, as: 'a'
      ctx.add_context b, as: 'b'
      ctx.add_context c, as: 'c'

    it "load all contexts", (done) ->
      ctx.load().then(
        ->
          expect(ctx.context('a')).to.eq a
          expect(a.state).to.eq 'loaded'
          expect(b.state).to.eq 'loaded'
          expect(c.state).to.eq 'loaded'
          done()
      ).catch(done)

    it "unload all contexts", (done) ->
      ctx.load().then(
        ->
          expect(ctx.context('a')).to.eq a
          ctx.unload()
      ).then(
        ->
          expect(a.state).to.eq 'unloaded'
          expect(b.state).to.eq 'unloaded'
          expect(c.state).to.eq 'unloaded'
          done()  
      ).catch(done)
