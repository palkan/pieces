'use strict'
TestHelpers = require './helpers'

utils = pi.utils

describe "pieces utils", ->
  describe "base utils", ->
    describe "uuid", ->
      it "should be uniq", ->
        expect(utils.uid()).to.not.equal utils.uid()

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


    describe "debounce and throttle", ->
      it "should invoke on first call", ->
        utils.debounce(500, (spy_fun = sinon.spy())).call(null)
        utils.throttle(500, (spy_fun2 = sinon.spy())).call(null)
        
        expect(spy_fun.callCount).to.equal 1
        expect(spy_fun2.callCount).to.equal 1

      it "should debounce/throttle call series", (done) ->
        fun = utils.debounce 200, (spy_fun = sinon.spy())
        fun2 = utils.throttle 200, (spy_fun2 = sinon.spy())
        
        utils.after 300, =>
          expect(spy_fun.callCount).to.equal 1
          expect(spy_fun.getCall(0).args[0]).to.eq 0
          expect(spy_fun2.callCount).to.equal 2
          expect(spy_fun2.getCall(1).args[0]).to.eq 3
          done()

        fun(0)
        fun2(0)
        fun(1)
        fun2(1)
        fun(2)
        fun2(2)
        fun(3)
        fun2(3)

      it "should invoke on first call after being used", (done) ->
        fun = utils.debounce 100, (spy_fun = sinon.spy())
        fun2 = utils.throttle 100, (spy_fun2 = sinon.spy())
        fun(1)
        fun2(1)
        fun(2)
        fun2(2)
        expect(spy_fun.callCount).to.equal 1
        expect(spy_fun2.callCount).to.equal 1
        utils.after 150, =>
          expect(spy_fun.callCount).to.equal 1
          expect(spy_fun2.callCount).to.equal 2
          expect(spy_fun2.getCall(1).args[0]).to.eq 2
          fun(4)
          expect(spy_fun.callCount).to.equal 2
          expect(spy_fun.getCall(1).args[0]).to.equal 4
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

    describe "extract", ->
      source = 
        id: 14
        name: "A" 
        tags: [
          {name: "cool", id: 1, type: "private"},
          {name: "hot", id: 2, type: "public"}
        ], 
        user: 
          id: 123 
          photo: 
            url: "http://image"
            thumb: "http://thumb"

      it "should extract top-level values", ->
        res = utils.extract(source, ['id', 'user'])
        expect(res.id).to.eq 14
        expect(res.user).to.have.keys('id', 'photo')

      it "should extract with subobjects filter values", ->
        res = utils.extract(source, ['id', {tags: ['id']}, {user: ['id', {photo: 'thumb'}]}])
        expect(res.id).to.eq 14
        expect(res.user).to.have.keys('id', 'photo')
        expect(res.tags).to.have.length 2
        expect(res.tags[0]).to.have.keys('id')
        expect(res.user.photo).to.have.keys('thumb')

    describe "to array", ->
      it "should return empty array if val is undefined", ->
        expect(utils.to_a()).to.have.length 0

      it "should return array of the length 1 if val is item", ->
        expect(utils.to_a(1)).to.have.length 1

      it "should return array itself if val is array", ->
        arr = [1]
        expect(utils.to_a(arr)).to.eql arr

  describe "array utils", ->
    describe "sorting", ->
      it "should sort by key", ->
        arr = [ {key: 1}, {key: 3}, {key: 2}, {key: -2} ]
        expect(utils.arr.sort_by(arr,'key', 'desc')).to.eql([ {key: 3}, {key: 2}, {key: 1}, {key: -2} ])

      it "should sort by key asc", ->
        arr = [ {key: 1}, {key: 3}, {key: 2}, {key: -2} ]
        expect(utils.arr.sort_by(arr,'key')).to.eql([ {key: -2}, {key: 1}, {key: 2}, {key: 3} ])

      it "should sort by many keys", ->
        arr = [ {key: 1, name: "bob"}, {key: 2, name: "jack"}, {key: 2, name: "doug"}, {key: -2} ]
        expect(utils.arr.sort(arr,[{key:'desc'},{name:'desc'}])).to.eql([ {key: 2, name:'jack'}, {key: 2, name: 'doug'}, {key: 1, name: 'bob'}, {key: -2} ])

      it "should sort by many keys asc", ->
        arr = [ {key: 1, name: "bob"}, {key: 2, name: "jack"}, {key: 2, name: "doug"}, {key: -2} ]
        expect(utils.arr.sort(arr,[{name:'asc'},{key:'asc'}],true)).to.eql([ {key: -2}, {key: 1, name: 'bob'}, {key: 2, name: 'doug'}, {key: 2, name:'jack'} ])

      it "should sort by many keys with diff orders", ->
        arr = [ {key: 1, name: "bob"}, {key: 2, name: "jack"}, {key: 2, name: "doug"}, {key: -2} ]
        expect(utils.arr.sort(arr,[{key:'desc'},{name:'asc'}],[false,true])).to.eql([ {key: 2, name:'doug'}, {key: 2, name: 'jack'}, {key: 1, name: 'bob'}, {key: -2} ])

      it "should sort serialized data", ->
        arr = [ {key: '12'}, {key: '31'}, {key: '2'}, {key: '-2'} ]
        expect(utils.arr.sort_by(arr,'key')).to.eql([ {key: '-2'}, {key: '2'}, {key: '12'}, {key: '31'} ])

    describe "sample", ->
      it "should return undefined if array is empty", ->
        expect(utils.arr.sample([])).to.be.undefined

      it "should return one element if size is 1", ->
        expect(utils.arr.sample([1,1,1])).to.eq 1

      it "should return array of size if size > 1", ->
        expect(utils.arr.sample([1,1,1],2)).to.have.length 2

      it "should return array of arr size if size > length", ->
        expect(utils.arr.sample([1],2)).to.have.length 1

      it "should return empty array if array is empty and size > 1", ->
        expect(utils.arr.sample([],2)).to.have.length 0

    describe "uniq", ->
      it "should return array of uniq values", ->
        expect(utils.arr.uniq([1,1,1,2,3,3,4,5,5,5])).to.have.length 5


  describe "object utils", ->
    describe "get/set path", ->
      source =
        data:
          id: 1
          options:
            active: true
            desc: "some data"
        id: 100

      it "should get value by path", ->
        expect(utils.obj.get_path(source, 'data.options.desc')).to.eq 'some data'
        expect(utils.obj.get_path(source, 'data.options.active')).to.be.true
        expect(utils.obj.get_path(source, 'data.secret.hash')).to.be.undefined
        expect(utils.obj.get_path(source, 'id')).to.eq 100

      it "should set value by path", ->
        data = {}
        utils.obj.set_path(data, 'options.visible', true)
        utils.obj.set_path(data, 'id', 1)
        utils.obj.set_path(data, 'options.secret.hash.value', 'abcdef123')
        expect(data.id).to.eq 1
        expect(data.options.visible).to.be.true
        expect(data.options.secret.hash.value).to.eq 'abcdef123'

    describe "wrap", ->
      it "should create key:val object", ->
        expect(utils.obj.wrap('id',1).id).to.eq 1

    describe "from array", ->
      it "should create object from array", ->
        expect(utils.obj.from_arr(['a',1,'b',2,'c',3])).to.have.keys('a','b','c')

