'use strict'
h = require 'pi/test/helpers'

describe "Pieces REST base", ->
  describe "resources association test", ->
    Chef = pi.resources.Chef
    Testo = pi.Testo2
    Eater = pi.Eater
    Assoc = pi.resources.Association

    beforeEach ->
      Chef.load [{id:1, name: 'Ivan', age: 100, coolness: 'hard'},{id:2, name: 'Kolyan', age: 30, coolness: 'medium'}]
      Testo.load [{type: 'drozhhi', id:10, chef_id: 1},{type: 'yeast', id:11, chef_id: 2}]
      Eater.load [{id:1,name: 'Karl', age: 23, weight: 67}, {id: 2, name: 'Luke', age: 65, weight: 124}]
      
    afterEach ->
      Testo.clear_all()
      Testo.off()
      Chef.clear_all()
      Chef.off()
      Eater.clear_all()
      Eater.off()

    describe "initialization", ->
      it "should respond to base methods", ->
        chef = Chef.get(1)
        expect(chef.load_testos).to.be.a('function')
        expect(chef.testos).to.be.a('function')
        expect(chef.eaters).to.be.a('function')
        expect(chef.testos()).to.be.an.instanceof(Assoc)
        expect(chef.eaters()).to.be.an.instanceof(Assoc)


      it "should handle resources events", ->
        chef = Chef.get(1)
        testos = chef.testos()
        spy = sinon.spy(testos, 'on_update')
        spy2 = sinon.spy(testos, 'on_destroy')

        t = Testo.get(10)
        t.set(value: 12)

        Testo.remove t

        expect(spy.callCount).to.eq 1
        expect(spy2.callCount).to.eq 1

      it "should handle resources events with belongs_to scope", ->
        chef = Chef.get(1)
        testos = chef.testos()
        spy = sinon.spy(testos, 'on_update')
        spy2 = sinon.spy(testos, 'on_destroy')

        t = Testo.get(11)
        t.set(value: 12)

        Testo.remove t

        expect(spy.callCount).to.eq 0
        expect(spy2.callCount).to.eq 0

        Testo.remove_by_id 10
        expect(spy2.callCount).to.eq 1

       it "should trigger resources events with belongs_to scope", ->
        chef = Chef.get(1)
        testos = chef.testos()
        spy = sinon.spy()
        testos.listen spy

        t = Testo.get(10)
        t.set(value: 12)

        Testo.remove t

        expect(spy.callCount).to.eq 2

      it "should init association on build", ->
        chef = Chef.build({id:3, name: 'Juan', eaters: [{id:3, kg_eaten: 12, name: 'Julio'}], testos: [{id:4, type: 'puff'}]})
        expect(chef.eaters().all()).to.have.length 1
        expect(chef.eaters().get(3).kg_eaten).to.eq 12
        expect(chef.testos().all()).to.have.length 1
        expect(chef.testos().get(4).chef_id).to.eq 3

      it "should update association on update", ->
        chef = Chef.build({id: 4, name: 'Juan'})
        chef.set eaters: [{id:3, kg_eaten: 12, name: 'Julio'}], testos: [{id:4, type: 'puff'}]
        expect(chef.eaters().all()).to.have.length 1
        expect(chef.eaters().get(3).kg_eaten).to.eq 12
        expect(chef.testos().all()).to.have.length 1
        expect(chef.testos().get(4).chef_id).to.eq 4

      it "should add resources already created", ->
        Testo.build id:90, type:'60s', chef_id:5
        chef = Chef.build id: 5, name: 'DelayedChef'
        expect(chef.testos().all()).to.have.length 1

      it "should add resources created outside with load", ->
        chef = Chef.build id: 6, name: 'Cheffo'
        Testo.load [{id:90, type:'70s', chef_id:6}]
        expect(chef.testos().all()).to.have.length 1

      it "should not add resources on update if not persisted", ->
        chef = Chef.build name: 'Cheffo'
        Eater.get(1).set(name: 'Romario')
        expect(chef.eaters().all()).to.have.length 0

    describe "add elements", ->
      beforeEach ->
        @chef = Chef.get(1)

      it "should add elements and handle updates", ->
        
        @chef.on 'update', (spy1 = sinon.spy())

        @chef.eaters().listen(spy = sinon.spy())
        @chef.eaters().build Eater.get(1)
        
        expect(spy.callCount).to.eq 1
        expect(spy1.callCount).to.eq 1
        expect(@chef.eaters().all()).to.have.length 1

        Eater.get(1).set({age: 101})
        expect(@chef.eaters().get(1).age).to.eq 101
        expect(spy1.callCount).to.eq 2

      it "should add elements, set owner_id and not copy", ->
        spy = sinon.spy()
        @chef.testos().listen spy
        @chef.testos().build {id:13, type:'none'}
        
        expect(spy.callCount).to.eq 1
        expect(@chef.testos().all()).to.have.length 2

        expect(@chef.testos().get(13).chef_id).to.eq @chef.id
        expect(@chef.testos().get(13)).to.be.an.instanceof Testo


      it "should add elements created outside with belongs_to", ->
        @chef.on 'update', (spy1 = sinon.spy())
        spy = sinon.spy()
        @chef.testos().listen spy
        Testo.build {id:13, type:'none', chef_id: @chef.id}
        
        expect(spy.callCount).to.eq 1
        expect(@chef.testos().all()).to.have.length 2
        expect(@chef.testos().get(13).type).to.eq 'none'
        expect(spy1.callCount).to.eq 0
        expect(@chef.testos_updated).to.be.undefined

      it "should add elements and handle remove", ->
        @chef.on 'update', (spy1 = sinon.spy())
        spy = sinon.spy()
        @chef.eaters().listen spy
        @chef.eaters().build Eater.get(1)
        
        expect(spy.callCount).to.eq 1
        expect(spy1.callCount).to.eq 1
        expect(@chef.eaters().all()).to.have.length 1

        Eater.remove_by_id(1)
        expect(@chef.eaters().all()).to.have.length 0
        expect(spy1.callCount).to.eq 2

      it "should handle remove of belongs_to", ->
        @chef.on 'update', (spy1 = sinon.spy())
        expect(@chef.testos().all()).to.have.length 1
        tid = @chef.testos().all()[0].id
        Testo.remove_by_id(tid)
        expect(@chef.testos().all()).to.have.length 0
        expect(spy1.callCount).to.eq 1
        expect(@chef.testos_updated).to.eq 1

    describe "destroy elements", ->
      beforeEach ->
        @chef = Chef.get(1)

      it "should destroy dependant elements", ->
        expect(@chef.testos().all()).to.have.length 1

        tid = @chef.testos().all()[0].id

        Chef.remove_by_id 1
        expect(Testo.get(tid)).to.be.undefined

    describe "serialize", ->
      beforeEach ->
        @chef = Chef.build({id:3, name: 'Juan', eaters: [Eater.get(1), Eater.get(2)], testos: [{id:4, type: 'puff'}]})
        @chef.eaters().get(1).set(kg_eaten:22)

      it "should serialize data correctly", ->
        data = @chef.attributes()

        expect(data.testos).to.have.length 1
        expect(data.eaters).to.have.length 2
        expect(data.eaters[0]).to.have.keys ['eater_id', 'kg_eaten']
        expect(data.testos[0]).to.have.keys ['id','chef_id','type']

    describe "reload after persist", ->
      it "should reload created associations", ->
        chef = Chef.build({name: 'Juan', eaters: [Eater.get(1), Eater.get(2)], testos: [{id: 4, type: 'puff'}]})
        expect(chef.testos().all()).to.have.length 1
        expect(chef.eaters().all()).to.have.length 2

        chef.set id: 3

        expect(chef.eaters().all()).to.have.length 2
        expect(chef.testos().all()).to.have.length 1

      it "should update cache after item created and updated", ->
        chef = Chef.build({id: 10, name: 'Juan', testos: [{type: 'puff'}]})
        expect(chef.testos().all()).to.have.length 1

        t = chef.testos().all()[0]

        t.set id: 14
        expect(chef.testos().all()).to.have.length 1
  
        t.set rate: 95
        expect(chef.testos().all()).to.have.length 1

    describe "several resources with REST associations", ->
      M = pi.resources.Meeting
      U = pi.resources.TestUsers

      beforeEach ->
        @m1 = M.build name: 'first', age: 22
        @m2 = M.build name: 'second', age: 33

      it "should load association", (done) ->
        @m1.load_users().then(
          =>
            expect(@m1.users_loaded).to.be.true
            expect(@m1.users().all()).to.have.length 2
            expect(@m2.users().all()).to.have.length 0
            expect(U.all()).to.have.length 0
            @m2.load_users().then(
              =>
                expect(@m1.users_loaded).to.be.true
                expect(@m2.users_loaded).to.be.true
                expect(@m1.users().all()).to.have.length 2
                expect(@m2.users().all()).to.have.length 4
                expect(U.all()).to.have.length 0
                done()
            )
        ).catch(
          (e) => done(e)
        )
        


