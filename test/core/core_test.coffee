'use strict'
h = require 'pieces-core/test/helpers'

describe "Core", ->
  it ".include", ->
    expect((new pi.Test3()).hello_world()).to.eq "ciao my world"

  it ".extend", ->
    expect(pi.Test2.enabled).to.be.undefined
    pi.Test2.enable()
    expect(pi.Test2.enabled).to.be.true

  it "#alias", ->
    expect((new pi.Test3()).hallo("hi")).to.eq "hi"

  it "#delegate_to", ->
    obj = 
      world: ()->
        "do do"
    t = new pi.Test()
    t.delegate_to obj, "world"
    expect(t.hello_world()).to.eq "hello do do" 

  describe ".getset", ->
    it "class", ->
      expect(pi.Test.available).to.be.undefined
      pi.Test.make_available() 
      expect(pi.Test.available).to.be.true
      pi.Test.available = 0
      expect(pi.Test.available).to.be.false

    it "instance", ->
      t = (new pi.Test4()).init("john")
      expect(t.inited).to.be.true

  describe ".register_callback", ->
    it "after", ->
      t = (new pi.Test4()).init("john")
      expect(t._inited).to.be.true
      expect(t.my_name).to.eq 'john 2'

    it "before", ->
      t = new pi.Test5()
      t.data.name = 'before'
      t.dispose()
      expect(t.data).to.be.undefined

    it "with promise", (done) ->
      t = new pi.Test5()
      p = t.dispose()
      expect(t.dispose_time).to.be.undefined
      p.then(
        ->  
          expect(t.dispose_time).to.be.above(99)
          done()
      ).catch(done)
