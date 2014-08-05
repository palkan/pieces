describe "core class", ->

  describe "class functions", ->
    it "should return class name", ->
      expect(pi.Test.class_name()).to.equal 'Test'

    it "should include mixin", ->
      expect((new pi.Test2()).world("hi")).to.eq "hi"
      expect((new pi.Test2()).has_renameable).to.be.true

    it "should include several mixins", ->
      expect((new pi.Test3()).hello_world()).to.eq "ciao my world"
      expect((new pi.Test3()).has_renameable).to.be.true
      expect((new pi.Test3()).has_helloable).to.be.true

    it "should support aliases", ->
      expect((new pi.Test3()).hallo("hi")).to.eq "hi"


  describe "instance functions", ->
    it "should return class name", ->
      expect((new pi.Test()).class_name()).to.equal 'Test'

    it "should include mixin", ->
      t = new pi.Test()
      t.include pi.TestComponent.Renameable
      expect(t.world("prive")).to.eq "prive"
      expect((new pi.Test()).hello_world()).to.eq "hello world"

    it "should include several mixins", ->
      t = new pi.Test()
      t.include pi.TestComponent.Renameable, pi.Base.Helloable
      expect(t.hello_world()).to.eq "ciao my world"
      expect((new pi.Test()).hello_world()).to.eq "hello world"

    it "should delegate methods to another object", ->
      obj = 
        world: ()->
          "do do"

      t = new pi.Test()
      t.delegate_to obj, "world"
      expect(t.hello_world()).to.eq "hello do do" 
   
