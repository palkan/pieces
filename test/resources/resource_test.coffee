describe "Pieces REST base", ->
  describe "base resources test", ->
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
      it "should return all resources", ->
        expect(Testo.all()).to.have.length 2
        expect(Salt.all()).to.have.length 2
        expect(Salt.get(2).name).to.eq 'gunsalt'

      it "should find item", ->
        expect(Salt.get(1).name).to.eq 'seasalt'
        expect(Salt.get(4)).to.be.undefined

      it "should destroy item", ->
        res = Salt.remove(1)
        expect(res.id).to.be.undefined
        expect(Salt.get(1)).to.be.undefined

    describe "instance functions", ->
      it "should update item", ->
        s = Salt.get(2)
        s.set salinity: 'high'
        s = Salt.get(2)
        expect(s.salinity).to.eq 'high'


    describe "update events", ->
      it "should send update event on create",(done) ->
        Testo.listen (e) ->
          expect(e.data.type).to.eq 'create'
          expect(e.data.testo.type).to.eq 'puff'
          done()
        Testo.build {type: 'puff', id: 3}

      it "should not send update event on build (without id)", (done) ->
        Testo.listen (e) ->
         throw Error('udpate received!')
        
        after 300, done

        Testo.build {type: 'puff'}

      it "should send update event on update",(done) ->
        t = Testo.all()[0]
        Testo.listen (e) ->
          expect(e.data.type).to.eq 'update'
          expect(e.data.testo.id).to.eq t.id
          expect(e.data.testo.type).to.eq 'yeast'
          expect(Testo.get(t.id).type).to.eq 'yeast'
          done()

        t.set {type: 'yeast'}

      it "should not send update event if no changes",(done) ->
        t = Testo.all()[1]
        Testo.listen (e) ->
          if e.data.type is 'update'
            throw Error('update received!')
       
        after 300, done

        t.set {type: 'blinno'}


     
