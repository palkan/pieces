'use strict'
h = require 'pieces-core/test/helpers'

describe "Resources", ->
  describe "ParamsFilter", ->
    class Testo extends $r.Base
      @set_resource 'testos'
      @params 'type', {flour: ['id', 'weight', {rye: ['type']} ]}, {salt: ['id', 'salinity']}

    afterEach ->
      Testo.clear_all()

    describe "#attributes", ->
      it "handle keys", ->
        t = new Testo({id:1, type: 'puff', _persisted: true})
        expect(t.attributes()).to.have.keys('id','type')

      it "nested attributes", ->
        t = new Testo({id:1, type: 'puff',_persisted: true, flour: {id:1, color:'white', weight: 'light', amount: 100, rye: {type: 'winter', year: 2014}}})
        expect(t.attributes()).to.have.keys('id','type','flour')
        expect(t.attributes().flour).to.have.keys('id','weight','rye')
        expect(t.attributes().flour.rye).to.have.keys('type')

      it "nested attributes 2", ->
        t = new Testo({id:1, flour: {id:1, color:'white', weight: 'light'}})
        t.set salt: [{id: 1, salinity: 'high', title: 'seasalt'},{id:2, salinity:'low', title:'limesos', comment: 'badsalt'}]
        expect(t.attributes()).to.have.keys('id','flour','salt')
        expect(t.attributes().salt).to.have.length 2
        expect(t.attributes().salt[1]).to.have.keys('id', 'salinity') 
