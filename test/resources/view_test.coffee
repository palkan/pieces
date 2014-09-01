'use strict'
TestHelpers = require '../rvc/helpers'

describe "Pieces REST base", ->
  describe "resources view test", ->
    Salt = pi.Salt
    Testo = pi.Testo
    View = pi.resources.View

    beforeEach ->
      Testo.load [{type: 'drozhhi', id:10},{type: 'blinno',id:11}]
      Salt.load [{id:1, name: 'seasalt'},{id:2, name: 'gunsalt'}]

    afterEach ->
      Testo.clear_all()
      Testo.off()
      Salt.clear_all()
      Salt.off()

    describe "initialization", ->
      it "should respond to base methods", ->
        view = new View(Testo)
        expect(view.load).to.be.a('function')
        expect(view.get).to.be.a('function')
        expect(view.remove).to.be.a('function')
        expect(view.remove_by_id).to.be.a('function')
        expect(view.where).to.be.a('function')
        expect(view.all).to.be.a('function')  

      it "should handle resources events", ->
        view = new View(Testo)
        spy = sinon.spy(view, 'on_update')
        spy2 = sinon.spy(view, 'on_destroy')

        t = Testo.get(10)
        t.set(value: 12)

        Testo.remove t

        expect(spy.callCount).to.eq 1
        expect(spy2.callCount).to.eq 1

      it "should handle resources events with scope", ->
        view = new View(Testo, type: 'blinno')
        spy = sinon.spy(view, 'on_update')
        spy2 = sinon.spy(view, 'on_destroy')

        t = Testo.get(10)
        t.set(value: 12)

        Testo.remove t
        expect(spy.callCount).to.eq 0
        expect(spy2.callCount).to.eq 0

        Testo.remove_by_id 11
        expect(spy2.callCount).to.eq 1

    describe "add elements", ->
      beforeEach ->
        @view = new View(Testo)

      afterEach ->
        @view.clear_all()
        @view.off()

      it "should add elements and handle updates", ->
        spy = sinon.spy()
        @view.listen spy
        @view.build Testo.get(10)
        
        expect(spy.callCount).to.eq 1
        expect(@view.all()).to.have.length 1

        Testo.get(10).set({type: 'blabla'})
        expect(@view.get(10).type).to.eq 'blabla'

      it "should add elements and handle remove", ->
        spy = sinon.spy()
        @view.listen spy
        @view.build Testo.get(10)
        
        expect(spy.callCount).to.eq 1
        expect(@view.all()).to.have.length 1

        Testo.remove_by_id(10)
        expect(@view.all()).to.have.length 0

    describe "serialize", ->
      beforeEach ->
        @view = new View(Testo,null, params: ['type', 'changed'])

      afterEach ->
        @view.clear_all()
        @view.off()

      it "should serialize data correctly", ->
        el = @view.build type: 'sugar', id: '12'
        el.changed = true

        data = @view.serialize()

        expect(data).to.have.length 1
        expect(data[0]).to.have.keys ['type', 'changed']
        expect(data[0].changed).to.eq true
