describe "core class", ->

  describe "class functions", ->
    it "should return class name", ->
      expect(pi.Test.class_name()).to.equal 'Test'

    it "should include mixin", ->
      expect((new pi.Test2()).world("hi")).to.eq "hi"

    it "should include several mixins", ->
      expect((new pi.Test3()).hello_world()).to.eq "ciao my world"

    it "should support aliases", ->
      expect((new pi.Test3()).hallo("hi")).to.eq "hi"

    it "should support callbacks", ->
      t = (new pi.Test4()).init("john")
      expect(t._inited).to.be.true
      expect(t.my_name).to.eq 'john 2'


  describe "instance functions", ->
    it "should return class name", ->
      expect((new pi.Test()).class_name()).to.equal 'Test'

    it "should delegate methods to another object", ->
      obj = 
        world: ()->
          "do do"

      t = new pi.Test()
      t.delegate_to obj, "world"
      expect(t.hello_world()).to.eq "hello do do" 
   
