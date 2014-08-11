describe "Pieces REST", ->
  describe "base resources test", ->
    Salt = pi.Salt
    Testo = pi.Testo

    beforeEach ->
      Testo.load [{type: 'drozhhi'},{type: 'blinno'}]
      Salt.load [{id:1, name: 'seasalt'},{id:2, name: 'gunsalt'}]

    afterEach ->
      Testo.delete_all()
      Testo.off()
      Salt.delete_all()
      Salt.off()

    describe "class functions", ->
      it "should return all resources", ->
        expect(Testo.all()).to.have.length 2
        expect(Salt.all()).to.have.length 2
        expect(Salt.find(2).name).to.eq 'gunsalt'

      it "should find item", ->
        expect(Salt.find(1).name).to.eq 'seasalt'
        expect(Salt.find(4)).to.be.undefined

      it "should destroy item", ->
        res = Salt.destroy(1)
        expect(res.id).to.be.undefined
        expect(Salt.find(1)).to.be.undefined

    describe "instance functions", ->
      it "should update item", ->
        s = Salt.find(2)
        s.update salinity: 'high'
        s = Salt.find(2)
        expect(s.salinity).to.eq 'high'

      it "should destroy item", ->
        s = Salt.find(1)
        s.destroy()
        expect(Salt.find(1)).to.be.undefined
        


    describe "update events", ->
      it "should send update event on create",(done) ->
        Testo.listen (e) ->
          expect(e.data.type).to.eq 'create'
          expect(e.data.testo.type).to.eq 'puff'
          done()
        Testo.create {type: 'puff'}

      it "should send update event on update",(done) ->
        t = Testo.all()[0]
        Testo.listen (e) ->
          expect(e.data.type).to.eq 'update'
          expect(e.data.testo.id).to.eq t.id
          expect(e.data.testo.type).to.eq 'yeast'
          expect(Testo.find(t.id).type).to.eq 'yeast'
          done()

        t.update {type: 'yeast'}

      it "should send update event on destroy",(done) ->
        t = Testo.all()[0]
        Testo.listen (e) ->
          expect(e.data.type).to.eq 'destroy'
          expect(Testo.find(t.id)).to.be.undefined
          done()
        t.destroy()


     
