'use strict'
TestHelpers = require '../rvc/helpers'

describe "Pieces REST", ->
  
  describe "rest resources test", ->
    Testo = pi.TestoRest
    R = $r.REST

    beforeEach ->
      TestHelpers.mock_net()

    afterEach ->
      Testo.clear_all()
      Testo.off()
      TestHelpers.unmock_net()

    describe "path interpolation", ->
      it "should interpolate without scope", ->
        expect(R._interpolate_path(":r/:id/edit", r: "rest", id: 1)).to.eq "/rest/1/edit"
        expect(R._interpolate_path("some/:id/any/:pid.json", pid: 2, id: 1)).to.eq "/some/1/any/2.json"
      
      it "should interpolate with scope", ->
        expect(Testo._interpolate_path(":resources/:id/edit", resources: "testos", id: 1)).to.eq "test/testos/1/edit.json"


    describe "class functions", ->
      it "should setup class methods", ->
        expect(Testo.show).to.be.a('function')
        expect(Testo.fetch).to.be.a('function')
        expect(Testo.destroy_all).to.be.a('function')

      it "should setup paths", ->
        expect(Testo.show_path).to.not.be.undefined
        expect(Testo.fetch_path).to.not.be.undefined
        expect(Testo.destroy_all_path).to.not.be.undefined

      it "should fetch data", (done) ->
        Testo.fetch().then(
          (items) -> 
            expect(items).to.have.length 3
            expect(Testo.all()).to.have.length 3
            done()
        )

      it "should fetch item (show)", (done) ->
        Testo.find(1).then(
          (item) -> 
            expect(item.type).to.eq 'yeast'
            expect(Testo.all()).to.have.length 1
            done()
        )

      it "should find item locally (sync)", (done) ->
        Testo.fetch().then(
          -> 
            expect(Testo.get(1)).to.be.an.instanceof Testo
            expect(Testo.all()).to.have.length 3
            done()
        )

      it "should create item", (done) ->
        Testo.create({type:"sugar"}).then(
          (item) ->
            expect(Testo.get(item.id).type).to.eq "sugar"
            done()
        )

    describe "instance functions", ->

      it "should setup member paths", ->
        t = new Testo({id:1, type: 'puff',_persisted: true})
        expect(t.update_path).to.not.be.undefined
        expect(t.create_path).to.not.be.undefined
        expect(t.destroy_path).to.not.be.undefined
        
      describe "attributes", ->
        it "should add only own attributes", ->
          t = new Testo({id:1, type: 'puff',_persisted: true})
          expect(t.attributes()).to.have.keys('id','type')
      
      it "should destroy element", (done) ->
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

      it "should destroy element and even it is not stored", (done) ->
        t = new Testo({id:1, type: 'puff',_persisted: true})
        Testo.listen (e) ->
          expect(e.data.type).to.eq 'destroy'
          expect(e.data.testo.type).to.eq 'puff'
          done()
          
        t.destroy()


      it "should save new element", (done) ->
        t = new Testo()
        t.type = '1'

        Testo.listen (e) ->
          expect(e.data.type).to.eq 'create'
          expect(e.data.testo.id).to.eq 4
          done()

        t.save()


      it "should save old element", (done) ->
        Testo.listen (e) ->
          expect(e.data.type).to.eq 'update'
          expect(e.data.testo.id).to.eq 1
          expect(Testo.get(1).type).to.eq 'dirt'
          done()

        Testo.find(1).then( (item) ->
          item.type = 'susi'
          item.save()
          )

