'use strict'
TestHelpers = require './helpers'

utils = pi.utils

describe "pieces utils", ->
  describe "escape regexp", ->
    it "should work", ->
      expect(utils.escapeRegexp("-{}()?*.$^\\")).to.equal("\\-\\{\\}\\(\\)\\?\\*\\.\\$\\^\\\\")

  describe "is email", ->
    it "should work with normal simple email", ->
      expect(utils.is_email("test@example.ru")).to.be.true
    it "should fail with stupid email", ->
      expect(utils.is_email("123,122@fff,ff")).to.be.false

    it "should not fail with dot-ended name email (though it is invalid due to RFC)", ->
      expect(utils.is_email("some.dot.ted.@email.com")).to.be.true

    it "should work with normal email with dots and digital domain", ->
      expect(utils.is_email("some.correct.dotted@112313.com")).to.be.true

  describe "is_html", ->
    it "should handle multiline html", ->
      expect(utils.is_html('<textarea>Kill\nMe!</textarea>')).to.be.true

  describe "trim string", ->
    it "should trim one word", ->
      expect(utils.trim(" qwertty  ")).to.eq 'qwertty'

    it "should trim sentence", ->
      expect(utils.trim(" how are yours?  ")).to.eq 'how are yours?'

    it "should trim multiline string", ->
      expect(utils.trim(" qwe\nrty ")).to.eq 'qwe\nrty' 

  describe "camel case", ->
    it "should work with one word", ->
      expect(utils.camelCase("worm")).to.equal("Worm")

    it "should work with a few words", ->
      expect(utils.camelCase("little_camel_in_the_desert")).to.equal("LittleCamelInTheDesert")

  describe "snake case", ->
    it "should work with a few words", ->
      expect(utils.snake_case("CamelSong")).to.equal("camel_song")

    it "should work with non-capitalized word", ->
      expect(utils.snake_case("camelSong")).to.equal("camel_song")

  describe "serialize", ->
    it "should recognize bool", ->
      expect(utils.serialize("true")).to.be.true
      expect(utils.serialize("false")).to.be.false

    it "should recognize empty string", ->
      expect(utils.serialize("")).to.eql ""

    it "should recognize integer number", ->
      expect(utils.serialize("123")).to.equal(123)

    it "should recognize float numer", ->
      expect(utils.serialize("2.6")).to.equal(2.6)

    it "should recognize string", ->
      expect(utils.serialize("123m535.35")).to.equal("123m535.35") 


  describe "sorting", ->
    it "should sort by key", ->
      arr = [ {key: 1}, {key: 3}, {key: 2}, {key: -2} ]
      expect(utils.sort_by(arr,'key', 'desc')).to.eql([ {key: 3}, {key: 2}, {key: 1}, {key: -2} ])

    it "should sort by key asc", ->
      arr = [ {key: 1}, {key: 3}, {key: 2}, {key: -2} ]
      expect(utils.sort_by(arr,'key')).to.eql([ {key: -2}, {key: 1}, {key: 2}, {key: 3} ])

    it "should sort by many keys", ->
      arr = [ {key: 1, name: "bob"}, {key: 2, name: "jack"}, {key: 2, name: "doug"}, {key: -2} ]
      expect(utils.sort(arr,[{key:'desc'},{name:'desc'}])).to.eql([ {key: 2, name:'jack'}, {key: 2, name: 'doug'}, {key: 1, name: 'bob'}, {key: -2} ])

    it "should sort by many keys asc", ->
      arr = [ {key: 1, name: "bob"}, {key: 2, name: "jack"}, {key: 2, name: "doug"}, {key: -2} ]
      expect(utils.sort(arr,[{name:'asc'},{key:'asc'}],true)).to.eql([ {key: -2}, {key: 1, name: 'bob'}, {key: 2, name: 'doug'}, {key: 2, name:'jack'} ])

    it "should sort by many keys with diff orders", ->
      arr = [ {key: 1, name: "bob"}, {key: 2, name: "jack"}, {key: 2, name: "doug"}, {key: -2} ]
      expect(utils.sort(arr,[{key:'desc'},{name:'asc'}],[false,true])).to.eql([ {key: 2, name:'doug'}, {key: 2, name: 'jack'}, {key: 1, name: 'bob'}, {key: -2} ])

    it "should sort serialized data", ->
      arr = [ {key: '12'}, {key: '31'}, {key: '2'}, {key: '-2'} ]
      expect(utils.sort_by(arr,'key')).to.eql([ {key: '-2'}, {key: '2'}, {key: '12'}, {key: '31'} ])


  describe "debounce", ->
    it "should invoke on first call", ->
      spy_fun = sinon.spy()
      fun = utils.debounce 500, spy_fun
      fun.call null
      expect(spy_fun.callCount).to.equal 1

    it "should debounce call series", (done) ->
      spy_fun = sinon.spy()
      fun = utils.debounce 200, spy_fun
      
      utils.after 300, =>
        expect(spy_fun.callCount).to.equal 2
        done()

      fun(0)
      fun(1)
      fun(2)
      fun(3)

    it "should invoke on first call after being used", (done) ->
      spy_fun = sinon.spy()
      fun = debounce 100, spy_fun
      fun.call null, 1
      fun.call null, 2
      expect(spy_fun.callCount).to.equal 1
      utils.after 150, =>
        expect(spy_fun.callCount).to.equal 2
        fun.call null, 4
        expect(spy_fun.callCount).to.equal 3
        done()

  describe "merge", ->
    it "should merge with empty object", ->
      to = {a:1,b:2}
      expect(utils.merge(to,{}).a).to.equal 1 
      expect(utils.merge(to,{}).b).to.equal 2 

    it "should merge correctly", ->
      to = {a:1,b:2}
      expect(utils.merge(to,{b:3}).a).to.equal 1 
      expect(utils.merge(to,{b:3}).b).to.equal 3 

  describe "merge", ->
    it "should merge with empty object", ->
      to = {a:1,b:2}
      expect(utils.merge(to,{}).a).to.equal 1 
      expect(utils.merge(to,{}).b).to.equal 2 

    it "should merge correctly", ->
      to = {a:1,b:2}
      expect(utils.merge(to,{b:3}).a).to.equal 1 
      expect(utils.merge(to,{b:3}).b).to.equal 3 
      expect(to.b).to.equal 2 

  describe "extend", ->
    it "should extend object", ->
      target = {a:1,b:2}
      expect(utils.extend(target,{b:3,c:4}).b).to.equal 2
      expect(target.b).to.equal 2
      expect(target.c).to.equal 4 

    it "should extend object with overwrite", ->
      target = {a:1,b:2}
      expect(utils.extend(target,{b:3,c:4},true).b).to.equal 3
      expect(target.b).to.equal 3
      expect(target.c).to.equal 4 

    it "should extend object with except", ->
      target = {a:1,b:2}
      expect(utils.extend(target,{b:3,c:4},false,["c"]).b).to.equal 2
      expect(target.b).to.equal 2
      expect(target.c).to.be.undefined