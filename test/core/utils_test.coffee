describe "pieces utils", ->
  describe "escape regexp", ->
    it "should work", ->
      expect(pi.utils.escapeRegexp("-{}()?*.$^\\")).to.equal("\\-\\{\\}\\(\\)\\?\\*\\.\\$\\^\\\\")

  describe "is email", ->
    it "should work with normal simple email", ->
      expect(pi.utils.is_email("test@example.ru")).to.be.true
    it "should fail with stupid email", ->
      expect(pi.utils.is_email("123,122@fff,ff")).to.be.false

    it "should not fail with dot-ended name email (though it is invalid due to RFC)", ->
      expect(pi.utils.is_email("some.dot.ted.@email.com")).to.be.true

    it "should work with normal email with dots and digital domain", ->
      expect(pi.utils.is_email("some.correct.dotted@112313.com")).to.be.true

  describe "camel case", ->
    it "should work with one word", ->
      expect(pi.utils.camelCase("worm")).to.equal("Worm")

    it "should work with a few words", ->
      expect(pi.utils.camelCase("little_camel_in_the_desert")).to.equal("LittleCamelInTheDesert")

  describe "snake case", ->
    it "should work with a few words", ->
      expect(pi.utils.snake_case("CamelSong")).to.equal("camel_song")

    it "should work with non-capitalized word", ->
      expect(pi.utils.snake_case("camelSong")).to.equal("camel_song")


  describe "serialize", ->
    it "should recognize bool", ->
      expect(pi.utils.serialize("true")).to.be.true
      expect(pi.utils.serialize("false")).to.be.false

    it "should recognize integer number", ->
      expect(pi.utils.serialize("123")).to.equal(123)

    it "should recognize float numer", ->
      expect(pi.utils.serialize("2.6")).to.equal(2.6)

    it "should recognize string", ->
      expect(pi.utils.serialize("123m535.35")).to.equal("123m535.35") 


  describe "sorting", ->
    it "should sort by key", ->
      arr = [ {key: 1}, {key: 3}, {key: 2}, {key: -2} ]
      expect(pi.utils.sort_by(arr,'key')).to.eql([ {key: 3}, {key: 2}, {key: 1}, {key: -2} ])

    it "should sort by key asc", ->
      arr = [ {key: 1}, {key: 3}, {key: 2}, {key: -2} ]
      expect(pi.utils.sort_by(arr,'key',true)).to.eql([ {key: -2}, {key: 1}, {key: 2}, {key: 3} ])

    it "should sort by many keys", ->
      arr = [ {key: 1, name: "bob"}, {key: 2, name: "jack"}, {key: 2, name: "doug"}, {key: -2} ]
      expect(pi.utils.sort(arr,['key','name'])).to.eql([ {key: 2, name:'jack'}, {key: 2, name: 'doug'}, {key: 1, name: 'bob'}, {key: -2} ])

    it "should sort by many keys asc", ->
      arr = [ {key: 1, name: "bob"}, {key: 2, name: "jack"}, {key: 2, name: "doug"}, {key: -2} ]
      expect(pi.utils.sort(arr,['name','key'],true)).to.eql([ {key: -2}, {key: 1, name: 'bob'}, {key: 2, name: 'doug'}, {key: 2, name:'jack'} ])

    it "should sort by many keys with diff orders", ->
      arr = [ {key: 1, name: "bob"}, {key: 2, name: "jack"}, {key: 2, name: "doug"}, {key: -2} ]
      expect(pi.utils.sort(arr,['key','name'],[false,true])).to.eql([ {key: 2, name:'doug'}, {key: 2, name: 'jack'}, {key: 1, name: 'bob'}, {key: -2} ])


  describe "debounce", ->
    it "should invoke on first call", ->
      spy_fun = sinon.spy()
      fun = debounce 500, spy_fun
      fun.call null
      expect(spy_fun.callCount).to.equal 1

    it "should debounce call series", (done) ->
      spy_fun = sinon.spy()
      fun = debounce 200, spy_fun
      
      after 300, =>
        expect(spy_fun.callCount).to.equal 2
        done()

      fun(0)
      fun(1)
      fun(2)
      fun(3)

  describe "merge", ->
    it "should merge with empty object", ->
      to = {a:1,b:2}
      expect(pi.utils.merge(to,{}).a).to.equal 1 
      expect(pi.utils.merge(to,{}).b).to.equal 2 

    it "should merge correctly", ->
      to = {a:1,b:2}
      expect(pi.utils.merge(to,{b:3}).a).to.equal 1 
      expect(pi.utils.merge(to,{b:3}).b).to.equal 3 

  describe "merge", ->
    it "should merge with empty object", ->
      to = {a:1,b:2}
      expect(pi.utils.merge(to,{}).a).to.equal 1 
      expect(pi.utils.merge(to,{}).b).to.equal 2 

    it "should merge correctly", ->
      to = {a:1,b:2}
      expect(pi.utils.merge(to,{b:3}).a).to.equal 1 
      expect(pi.utils.merge(to,{b:3}).b).to.equal 3 
      expect(to.b).to.equal 2 

  describe "extend", ->
    it "should extend object", ->
      target = {a:1,b:2}
      expect(pi.utils.extend(target,{b:3,c:4}).b).to.equal 2
      expect(target.b).to.equal 2
      expect(target.c).to.equal 4 