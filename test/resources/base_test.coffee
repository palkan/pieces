'use strict'
h = require 'pieces/test/helpers'

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
      it "return all resources", ->
        expect(Testo.all()).to.have.length 2
        expect(Salt.all()).to.have.length 2
        expect(Salt.get(2).name).to.eq 'gunsalt'

      it "find item", ->
        expect(Salt.get(1).name).to.eq 'seasalt'
        expect(Salt.get(4)).to.be.undefined

      it "find many items (where)", ->
        expect(Salt.where({name: 'seasalt'})).to.have.length 1
        expect(Salt.where({'id>':2})).to.have.length 1
        expect(Salt.where({'name~':'salt'})).to.have.length 2

      it "destroy item", ->
        res = Salt.remove_by_id(1)
        expect(res.id).to.be.undefined
        expect(Salt.get(1)).to.be.undefined

    describe "instance functions", ->
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

      it "bind events to item", ->
        s = Salt.get(1)
        s2 = Salt.get(2)

        spy = sinon.spy()

        s.on 'update', spy

        s2.set({salinity: 'low'})
        s.set({salinity: 'very high'})

        expect(spy.callCount).to.eq 1

      it "unbind events from item", ->
        s = Salt.get(1)

        spy = sinon.spy()
        s.on 'update', spy
        s.set({salinity: 'very high'})

        s.off spy
        s.set({sugar: 'brown'})
        expect(spy.callCount).to.eq 1

      it "send update event with changes",(done) ->
        s = Salt.get(1)
        s.on 'update', (e) ->
          expect(e.type).to.eq 'update'
          expect(e.data.sugar[0]).to.be.undefined
          expect(e.data.sugar[1]).to.eq 'brown'
          done()

        s.set({sugar: 'brown'})

    describe "update events", ->
      it "send update event on create",(done) ->
        Testo.listen (e) ->
          expect(e.data.type).to.eq 'create'
          expect(e.data.testo.type).to.eq 'puff'
          done()
        Testo.build {type: 'puff', id: 3}

      it "not send update event on build (without id)", (done) ->
        Testo.listen (e) ->
         done('udpate received!')
        
        utils.after 300, done

        Testo.build {type: 'puff'}

      it "send update event on update with changes",(done) ->
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

      it "not send update event if no changes",(done) ->
        t = Testo.second()
        Testo.listen (e) ->
          if e.data.type is 'update'
            throw Error('update received!')
       
        utils.after 300, done

        t.set {type: 'blinno'}

      it "send update event on destroy event if element is not stored",(done) ->
        t = new Testo({type: 'hoho', id: 123})
        Testo.listen (e) ->
          expect(e.data.type).to.eq 'destroy'
          expect(e.data.testo.id).to.eq 123
          expect(e.data.testo.type).to.eq 'hoho'
          done()
        Testo.remove t

    describe "working with temp_id", ->
      it "send create event on set with id and remove __temp__ prop",(done) ->
        Testo.listen (e) ->
          expect(e.data.type).to.eq 'create'
          expect(e.data.testo.__temp__).to.be.undefined
          done()
        t = Testo.build {type: 'puff'}
        t.set {id: 12}
