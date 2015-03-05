'use strict'
h = require 'pi/test/helpers'

describe "Core", ->

  describe "class functions", ->
    it "mixin", ->
      expect((new pi.Test2()).world("hi")).to.eq "hi"

    it "mixin with several args", ->
      expect((new pi.Test3()).hello_world()).to.eq "ciao my world"

    it "aliases", ->
      expect((new pi.Test3()).hallo("hi")).to.eq "hi"

    it "callbacks", ->
      t = (new pi.Test4()).init("john")
      expect(t._inited).to.be.true
      expect(t.my_name).to.eq 'john 2'


  describe "instance functions", ->
    it "delegate_to", ->
      obj = 
        world: ()->
          "do do"
      t = new pi.Test()
      t.delegate_to obj, "world"
      expect(t.hello_world()).to.eq "hello do do" 
   