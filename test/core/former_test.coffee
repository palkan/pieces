'use strict'
h = require 'pieces/test/helpers'

describe "Former", ->
  root = h.test_cont(pi.Nod.body)

  Former = require '../../core/former/former'

  after ->
    root.remove()

  describe "parse", ->
    it "parse simple name values (without nested objects)", ->
      f = new Former()

      name_values = [
        {name: 'a', value: "1"},
        {name: 'b', value: "2"},
        {name: 'c', value: "3"}
      ]

      expect(f.process_name_values(name_values)).to.include({a:"1",b:"2",c:"3"})

    it "parse name values on object (without arrays)", ->
      f = new Former()

      name_values = [
        {name: "obj.a", value: "1"},
        {name: "obj.b", value: "2"},
        {name: "obj.c", value: "3"}
      ]

      expect(f.process_name_values(name_values)["obj"]).to.include({a:"1",b:"2",c:"3"})

    it "parse complex name values on objects (without arrays)", ->
      f = new Former()

      name_values = [
        {name: "obj.a", value: "1"},
        {name: "obj2.b", value: "2"},
        {name: "obj.c", value: "3"},
        {name: "obj2.d.id",value: "4"},
        {name: "obj2.d.name",value: "5"},
        {name: "obj.n1.n2.n3.id", value: "6"}
      ]

      data = f.process_name_values(name_values)

      expect(data["obj"]).to.include({a:"1",c:"3"})
      expect(data["obj2"]["d"]).to.include({id:"4",name:"5"})
      expect(data["obj"]["n1"]["n2"]["n3"]).to.include({id:"6"})


    it "parse name values with arrays", ->
      f = new Former()

      name_values = [
        {name: "obj.a[]", value: "1"},
        {name: "obj.a[]", value: "2"},
        {name: "obj.c", value: "3"},
        {name: "obj.a[]", value: "6"}
      ]

      data = f.process_name_values(name_values)

      expect(data["obj"]).to.include({c:"3"})
      expect(data["obj"]["a"]).to.have.length(3)
      expect(data["obj"]["a"]).to.eql(['1','2','6'])


    it "parse name values with nested arrays", ->
      f = new Former()

      name_values = [
        {name: "obj.a[].id", value: "1"},
        {name: "obj.a[].tags[]", value: "a"},
        {name: "obj.a[].tags[]", value: "b"},
        {name: "obj.a[].id", value: "2"},
        {name: "obj.a[].tags[]", value: "c"}
      ]

      data = f.process_name_values(name_values)

      expect(data["obj"]["a"]).to.have.length(2)
      expect(data["obj"]["a"][0]['tags']).to.eql(['a','b'])
      expect(data["obj"]["a"][1]['tags']).to.eql(['c'])




    it "parse name values very complex", ->
      f = new Former()

      name_values = [
        {name: "obj.a[].id", value: "1"},
        {name: "obj.a[].tags[]", value: "a"},
        {name: "obj.a[].tags[]", value: "b"},
        {name: "obj.a[].id", value: "2"},
        {name: "obj.a[].tags[]", value: "c"},
        {name: "obj.a[].users[].id", value: "10"},
        {name: "obj.a[].users[].id", value: "11"},
        {name: "obj.a[].users[].id", value: "13"},
        {name: "obj.a[].id", value: "3"},
        {name: "obj.a[].comments[].author", value: "A"},
        {name: "obj.a[].comments[].likes[]", value: "10"},
        {name: "obj.a[].comments[].likes[]", value: "12"},
        {name: "obj.a[].comments[].author", value: "B"},
        {name: "obj.a[].comments[].likes[]", value: "11"},
        {name: "obj.a[].tags[]", value: 'd'},
        {name: "obj.a[].tags[]", value: 'e'}
      ]

      data = f.process_name_values(name_values)

      expect(data["obj"]["a"]).to.have.length(3)
      expect(data["obj"]["a"][0]['tags']).to.eql(['a','b'])
      expect(data["obj"]["a"][1]['tags']).to.eql(['c'])
      expect(data["obj"]["a"][1]['users']).to.have.length(3)
      expect(data["obj"]["a"][2]['comments']).to.have.length(2)
      expect(data["obj"]["a"][2]['comments'][0]['likes']).to.eql(['10','12'])

    ## Bug from teachbase
    it "parse arrays of nested objects (rails)", ->
      f = new Former(null, {rails: true})
      data = f.process_name_values([{name: 'users[][labels[12]]',value: 1},{name:'users[][labels[15]]',value:2}])

      expect(data["users"]).to.have.length(1)
      expect(data["users"][0]["labels"]["12"]).to.eql(1)
      expect(data["users"][0]["labels"]["15"]).to.eql(2)

    it "parse rails names and serialize data", ->
      f = new Former(null, serialize: true, rails: true)

      name_values = [
        {name: "model[a][][id]", value: "1"},
        {name: "model[a][][tags][]", value: "a"},
        {name: "model[a][][tags][]", value: "b"},
        {name: "model[a][][id]", value: "2"},
        {name: "model[a][][tags][]", value: "c"},
        {name: "model[flag]", value: "true"}
      ]

      data = f.process_name_values(name_values)

      expect(data["model"]["a"]).to.have.length(2)
      expect(data["model"]["a"][0]['tags']).to.eql(['a','b'])
      expect(data["model"]["a"][0]['id']).to.eql(1)
      expect(data["model"]["a"][1]['tags']).to.eql(['c'])    
      expect(data["model"]["a"][1]['id']).to.eql(2)
      expect(data["model"]["flag"]).to.eql(true)

    it "parse rails datetime names", ->
      f = new Former(null, rails: true)

      name_values = [
        {name: "model[created_at(2i)]", value: "7"},
        {name: "model[created_at(1i)]", value: "2014"},
        {name: "model[created_at(3i)]", value: "1"}
      ]

      data = f.process_name_values(name_values)

      expect(data["model"]["created_at(1i)"]).to.equal '2014'
      expect(data["model"]["created_at(2i)"]).to.equal '7'
      expect(data["model"]["created_at(3i)"]).to.equal '1'

     it "parse nested rails names", ->
      f = new Former(null, rails: true)

      name_values = [
        {name: "model[created_at[month]]", value: "7"},
        {name: "model[created_at[year]]", value: "2014"},
        {name: "model[created_at[day]]", value: "1"}
      ]

      data = f.process_name_values(name_values)

      expect(data["model"]["created_at"]["year"]).to.equal '2014'
      expect(data["model"]["created_at"]["month"]).to.equal '7'
      expect(data["model"]["created_at"]["day"]).to.equal '1'

  describe "fill and clear", ->
    test_form = null
    beforeEach ->
      test_form = document.createElement('form')

      test_form.appendChild h.inputElement('text','post.name','Name')
      
      cb = h.inputElement('checkbox','post.is_private','1')
      cb.checked = true
      test_form.appendChild cb

      test_form.appendChild h.inputElement('checkbox','post.is_draft','1')
      test_form.appendChild h.selectElement('post.category',false,{value:'sports',selected:true},{value:'politics'})
  
      test_form.appendChild h.inputElement('text','post.tags[]','football')
      test_form.appendChild h.inputElement('text','post.tags[]','uefa')

      test_form.appendChild h.selectElement('post.lang',true,{value:'ru',selected:true},{value:'en'},{value:'es'},{value:'de',selected:true})

      test_form.appendChild h.inputElement('hidden','post.parent_id','123')

      root.append(test_form)

    it "collect form data", ->
      data = Former.parse(test_form, serialize: true)
      expect(data["post"]["is_private"]).to.eql(1)
      expect(data["post"]["is_draft"]).to.be.undefined
      expect(data["post"]["category"]).to.eql('sports')    
      expect(data["post"]["tags"]).to.eql(['football','uefa'])
      expect(data["post"]["lang"]).to.eql(['ru','de'])

    it "fill form data", ->
      f = new Former(test_form, serialize: true, fill_prefix: 'post.')
      f.fill name: 'Zeit', is_draft: true, is_private: false, category: 'politics', lang: 'es'

      data = f.parse()

      expect(data["post"]["is_private"]).to.be.undefined
      expect(data["post"]["is_draft"]).to.eql(1)
      expect(data["post"]["category"]).to.eql('politics')    
      expect(data["post"]["tags"]).to.eql(['football','uefa'])
      expect(data["post"]["lang"]).to.eql(['es'])

    it "clear form", ->
      Former.clear(test_form)

      data = Former.parse(test_form)

      expect(data.post.name).to.be.empty
      expect(data.post.lang).to.be.empty
      expect(data.post.parent_id).to.equal('123')

    it "clear hidden elements when 'clear_hidden' is true", ->
      Former.clear(test_form, clear_hidden: true)

      data = Former.parse(test_form)

      expect(data.post.name).to.be.empty
      expect(data.post.lang).to.be.empty
      expect(data.post.parent_id).to.be.empty
