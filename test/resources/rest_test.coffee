'use strict'
h = require 'pi/test/helpers'

describe "Resources", ->
  describe "REST", ->
    Testo = pi.TestoRest
    Salt = pi.Salt
    Testo2 = pi.TestoRest2
    Wrap = pi.TestoWrap
    R = $r.REST

    beforeEach ->
      h.mock_net()

    afterEach ->
      Testo.clear_all()
      Testo.off()
      Salt.clear_all()
      h.unmock_net()

    describe "path interpolation", ->
      it "interpolate without scope", ->
        expect(R._interpolate_path(":r/:id/edit", r: "rest", id: 1)).to.eq "/rest/1/edit"
        expect(R._interpolate_path("some/:id/any/:pid.json", pid: 2, id: 1)).to.eq "/some/1/any/2.json"
      
      it "interpolate with scope", ->
        expect(Testo._interpolate_path(":resources/:id/edit", resources: "testos", id: 1)).to.eq "test/testos/1/edit.json"

      it "interpolate with scope including params", ->
        expect(Testo2._interpolate_path(":id/edit", id: 1, type: 'yeast')).to.eq "types/yeast/test/1/edit.json"

      it "interpolate with target params", ->
        t = Testo2.build type: 'yeast', id: 1
        expect(Testo2._interpolate_path(":id/edit",{},t)).to.eq "types/yeast/test/1/edit.json"

      it "interpolate with wrapped params", ->
        expect(Wrap._interpolate_path(":id/:type/edit",{testo:{type: 'gut', id:12}})).to.eq "/12/gut/edit"

    describe "class functions", ->
      it "setup class methods", ->
        expect(Testo.show).to.be.a('function')
        expect(Testo.fetch).to.be.a('function')
        expect(Testo.destroy_all).to.be.a('function')

      it "setup paths", ->
        expect(Testo.show_path).to.not.be.undefined
        expect(Testo.fetch_path).to.not.be.undefined
        expect(Testo.destroy_all_path).to.not.be.undefined

      it "fetch data", (done) ->
        Testo.fetch().then(
          (data) -> 
            expect(data.testos).to.have.length 3
            expect(Testo.all()).to.have.length 3
            done()
        )

      it "fetch item (show)", (done) ->
        Testo.find(1).then(
          (item) -> 
            expect(item.type).to.eq 'yeast'
            expect(Testo.all()).to.have.length 1
            done()
        )

      it "find item locally (sync)", (done) ->
        Testo.fetch().then(
          -> 
            expect(Testo.get(1)).to.be.an.instanceof Testo
            expect(Testo.all()).to.have.length 3
            done()
        )

      it "create item", (done) ->
        Testo.create({type:"sugar"}).then(
          (item) ->
            expect(Testo.get(item.id).type).to.eq "sugar"
            done()
        )

      it "run save callbacks and add save additional params", ->
        t = new Testo({})
        t.create = (data) -> data
        attrs = t.save(sugar: true)
        expect(attrs.type).to.eq 'normal'
        expect(attrs.sugar).to.be.true

    describe "dependant resources", ->
      it "fetch data and create deps", (done) ->
        Testo.fetch().then(
          (data) -> 
            expect(data.testos).to.have.length 3
            expect(Testo.all()).to.have.length 3
            expect(Salt.all()).to.have.length 1
            done()
        )

      it "fetch item (show) and deps", (done) ->
        Testo.find(1).then(
          (item) -> 
            expect(item.type).to.eq 'yeast'
            expect(Testo.all()).to.have.length 1
            expect(Salt.all()).to.have.length 1
            done()
        )

    describe "instance functions", ->

      it "setup member paths", ->
        t = new Testo({id:1, type: 'puff',_persisted: true})
        expect(t.update_path).to.not.be.undefined
        expect(t.create_path).to.not.be.undefined
        expect(t.destroy_path).to.not.be.undefined
        
      describe "attributes", ->
        it "add only described attributes", ->
          t = new Testo({id:1, type: 'puff',_persisted: true})
          expect(t.attributes()).to.have.keys('id','type')

        it "filter nested attributes", ->
          t = new Testo({id:1, type: 'puff',_persisted: true, flour: {id:1, color:'white', weight: 'light', amount: 100, rye: {type: 'winter', year: 2014}}})
          expect(t.attributes()).to.have.keys('id','type','flour')
          expect(t.attributes().flour).to.have.keys('id','weight','rye')
          expect(t.attributes().flour.rye).to.have.keys('type')

        it "filter nested attributes 2", ->
          t = new Testo({id:1, flour: {id:1, color:'white', weight: 'light'}})
          t.set salt: [{id: 1, salinity: 'high', title: 'seasalt'},{id:2, salinity:'low', title:'limesos', comment: 'badsalt'}]
          expect(t.attributes()).to.have.keys('id','flour','salt')
          expect(t.attributes().salt).to.have.length 2
          expect(t.attributes().salt[1]).to.have.keys('id', 'salinity') 

      it "destroy element", (done) ->
        Testo.fetch().then(
          ->
            Testo.listen (e) ->
              expect(e.data.type).to.eq 'destroy'
            Testo.get(1).destroy().then(
              ->
                expect(Testo.all()).to.have.length 2
                expect(Testo.get(1)).to.be.undefined   
                done()           
            )
        )

      it "destroy element and even it is not stored", (done) ->
        t = new Testo({id:1, type: 'puff',_persisted: true})
        Testo.listen (e) ->
          expect(e.data.type).to.eq 'destroy'
          expect(e.data.testo.type).to.eq 'puff'
          done()
        t.destroy()

      it "remove unpersisted element when 'destroy'", (done) ->
        t = Testo.build({type: 'puff'})
        Testo.listen (e) ->
          expect(e.data.type).to.eq 'destroy'
          expect(e.data.testo.type).to.eq 'puff'
          done()
        t.destroy()

      it "save new element", (done) ->
        t = new Testo()
        t.type = '1'

        Testo.listen (e) ->
          expect(e.data.type).to.eq 'create'
          expect(e.data.testo.id).to.eq 4
          done()

        t.save()

      it "save old element", (done) ->
        Testo.listen ((e) ->
          expect(e.data.type).to.eq 'update'
          expect(e.data.testo.id).to.eq 1
          expect(Testo.get(1).type).to.eq 'dirt'
          done()
          ),
          ((e) -> e.data.type is 'update')

        Testo.find(1).then( (item) ->
          item.type = 'susi'
          item.save()
          )
