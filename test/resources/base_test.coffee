'use strict'
h = require 'pieces-core/test/helpers'

describe "Resources", ->
  utils = pi.utils
  describe "Base", ->
    Salt = pi.Salt
    Testo = pi.Testo

    beforeEach ->
      Testo.load [{type: 'drozhhi', id:10},{type: 'blinno',id:11}]
      Salt.load [{id:1, name: 'seasalt'},{id:2, name: 'gunsalt'}]

    afterEach ->
      Testo.clear_all()
      Testo.off()
      Salt.clear_all()
      Salt.off()

    describe "class functions", ->
      it ".all", ->
        expect(Testo.all()).to.have.length 2
        expect(Salt.all()).to.have.length 2
        expect(Salt.get(2).name).to.eq 'gunsalt'

      it ".get", ->
        expect(Salt.get(1).name).to.eq 'seasalt'
        expect(Salt.get(4)).to.be.undefined

      it ".where", ->
        expect(Salt.where({name: 'seasalt'})).to.have.length 1
        expect(Salt.where({'id>':2})).to.have.length 1
        expect(Salt.where({'name~':'salt'})).to.have.length 2

      it ".remove_by_id", ->
        res = Salt.remove_by_id(1)
        expect(res.id).to.be.undefined
        expect(Salt.get(1)).to.be.undefined

      describe ".listen", ->
        it "send update event on create", (done) ->
          Testo.listen (e) ->
            expect(e.data.type).to.eq 'create'
            expect(e.data.testo.type).to.eq 'puff'
            done()
          Testo.build {type: 'puff', id: 3}

        it "don't send update event without id", ->
          Testo.listen (spy = sinon.spy())
          Testo.build {type: 'puff'}
          expect(spy.callCount).to.eq 0

        it "update event contains changes", (done) ->
          t = Testo.first()
          Testo.listen (e) ->
            expect(e.data.type).to.eq 'update'
            expect(e.data.testo.id).to.eq t.id
            expect(e.data.testo.type).to.eq 'yeast'
            expect(e.data.changes.type[0]).to.eq 'drozhhi'
            expect(e.data.changes.type[1]).to.eq 'yeast'
            expect(Testo.get(t.id).type).to.eq 'yeast'
            done()

          t.set {type: 'yeast'}

        it "don't send update if no changes", ->
          t = Testo.second()
          Testo.listen (spy = sinon.spy())
          t.set {type: 'blinno'}
          expect(spy.callCount).to.eq 0

        it "send 'destroy' event if element was not persisted", (done) ->
          t = new Testo({type: 'hoho', id: 123})
          Testo.listen (e) ->
            expect(e.data.type).to.eq 'destroy'
            expect(e.data.testo.id).to.eq 123
            expect(e.data.testo.type).to.eq 'hoho'
            done()
          Testo.remove t

    describe "#set", ->
      it "update item", ->
        s = Salt.get(2)
        s.set salinity: 'high'
        s = Salt.get(2)
        expect(s.salinity).to.eq 'high'

      it "track changes", ->
        s = Salt.get(2)
        s.set salinity: 'high'
        expect(s.salinity).to.eq 'high'
        expect(s.changes).to.have.keys('salinity')
        expect(s.changes.salinity[0]).to.be.undefined
        expect(s.changes.salinity[1]).to.eq 'high'
        s.commit()
        expect(s.changes).to.be.empty

    describe "events", ->
      it "#on 'update'", ->
        s = Salt.get(1)
        s2 = Salt.get(2)
        s.on 'update', (spy = sinon.spy())
        s2.set({salinity: 'low'})
        s.set({salinity: 'very high'})
        expect(spy.callCount).to.eq 1

      it "#off", ->
        s = Salt.get(1)
        spy = sinon.spy()
        s.on 'update', spy
        s.set({salinity: 'very high'})
        s.off spy
        s.set({sugar: 'brown'})
        expect(spy.callCount).to.eq 1

      it "update event contains changes",(done) ->
        s = Salt.get(1)
        s.on 'update', (e) ->
          expect(e.type).to.eq 'update'
          expect(e.data.sugar[0]).to.be.undefined
          expect(e.data.sugar[1]).to.eq 'brown'
          done()
        s.set({sugar: 'brown'})

    describe "temp_id", ->
      it "send 'create' event when id is set and remove __temp__ prop", (done) ->
        Testo.listen (e) ->
          expect(e.data.type).to.eq 'create'
          done()
        t = Testo.build {type: 'puff'}
        t.set {id: 12}

      it "remove __temp__ prop", (done) ->
        t = Testo.build {type: 'puff'}
        Testo.listen (e) ->
          expect(e.data.testo.__temp__).to.be.undefined
          expect(t.__temp__).to.be.undefined
          expect(t._persisted).to.be.true
          done()
        t.set {id: 12}
