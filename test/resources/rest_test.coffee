'use strict'
h = require 'pieces-core/test/helpers'

describe "Resources", ->
  describe "REST", ->
    Testo = pi.TestoRest
    Salt = pi.Salt
    Testo2 = pi.TestoRest2
    Wrap = pi.TestoWrap
    R = pi.Testo2

    beforeEach ->
      h.mock_net()

    afterEach ->
      Testo.clear_all()
      Testo.off()
      Salt.clear_all()
      h.unmock_net()
      $r.REST.globals({})

    describe "action paths", ->
      it "collection paths", ->
        t = Testo.storage
        expect(t.find_path).to.not.be.undefined
        expect(t.fetch_path).to.not.be.undefined
        expect(t.destroy_all_path).to.not.be.undefined

      it "member paths", ->
        t = Testo.storage
        expect(t.update_path).to.not.be.undefined
        expect(t.create_path).to.not.be.undefined
        expect(t.destroy_path).to.not.be.undefined

    describe ".path", ->
      it "without namespace", ->
        expect(R.path(":r/:id/edit", r: "rest", id: 1)).to.eq "/rest/1/edit"
        expect(R.path("some/:id/any/:pid.json", pid: 2, id: 1)).to.eq "/some/1/any/2.json"
      
      it "with namespace", ->
        expect(Testo.path("update", resources: "testos", id: 1)).to.eq "test/testos/1.json"

      it "with namespace including params", ->
        expect(Testo2.path(":id/edit", id: 1, type: 'yeast')).to.eq "types/yeast/test/1/edit.json"

      it "with globals", ->
        $r.REST.globals(user: 1)
        expect(Wrap.path("users/:user/:id/:type/edit",type: 'gut', id:12)).to.eq "/users/1/12/gut/edit"

    describe "#path", ->
      it "with target params", ->
        t = Testo2.build type: 'yeast', id: 1
        expect(t.path(":id/edit")).to.eq "types/yeast/test/1/edit.json"

    describe "class functions", ->
      it "delegations", ->
        expect(Testo.destroy_all).to.be.a('function')

      it ".fetch", (done) ->
        Testo.fetch().then(
          (data) -> 
            expect(data.testos).to.have.length 3
            expect(Testo.all()).to.have.length 3
            done()
        ).catch(done)

      it ".find", (done) ->
        Testo.find(1).then(
          (item) -> 
            expect(item.type).to.eq 'yeast'
            expect(Testo.all()).to.have.length 1
            done()
        ).catch(done)

      it ".create", (done) ->
        Testo.create({type:"sugar"}).then(
          (data) ->
            expect(Testo.get(data.testo.id).type).to.eq "sugar"
            done()
        ).catch(done)

    describe "callbacks", ->
      it "#before_save", ->
        t = new Testo({})
        t.save(sugar: true)
        expect(t.type).to.eq 'normal'

      it "#after_save", (done) ->
        t = new Testo({})
        t.save(sugar: true).then( ->
          expect(t._saved).to.be.true
          done()
        ).catch(done)

    describe ".can_create", ->
      it "on .fetch", (done) ->
        Testo.fetch().then(
          (data) -> 
            expect(data.testos).to.have.length 3
            expect(Salt.all()).to.have.length 1
            done()
        ).catch(done)

      it "on .find", (done) ->
        Testo.find(1).then(
          (item) -> 
            expect(item.type).to.eq 'yeast'
            expect(Testo.all()).to.have.length 1
            expect(Salt.all()).to.have.length 1
            done()
        ).catch(done)


    describe "#destroy", ->
      it "persistent", (done) ->
        Testo.fetch().then(
          ->
            Testo.listen (e) ->
              expect(e.data.type).to.eq 'destroy'
            Testo.get(1).destroy()
        ).then(
          ->
            expect(Testo.all()).to.have.length 2
            expect(Testo.get(1)).to.be.undefined   
            done()           
        ).catch(done)

      it "unpersisted", (done) ->
        t = Testo.build({type: 'puff'})
        Testo.listen (e) ->
          expect(e.data.type).to.eq 'destroy'
          expect(e.data.testo.type).to.eq 'puff'
          done()
        t.destroy()

    describe "#save", ->
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
        ).catch(done)
