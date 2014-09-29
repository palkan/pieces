'use strict'
TestHelpers = require '../rvc/helpers'

describe "Pieces REST base", ->
  describe "resources has_one test", ->
    User = pi.resources.User
    Profile = pi.resources.Profile
    
    afterEach ->
      User.off()
      Profile.clear_all()
      User.clear_all()
      
    describe "initialization", ->
      it "should init association on build", ->
        usr = User.build({id:3, name: 'Juan', email: 'juan@dogeater.com', profile: {id: 1, age: 10, weight: 122, height: 164}})
        expect(usr.profile.age).to.eq 10
        expect(usr.profile.user_id).to.eq 3
        expect(Profile.all()).to.have.length 1
        expect(User.all()).to.have.length 1

      it "should update association on update", ->
        usr = User.build({id:3, name: 'Juan', email: 'juan@dogeater.com', profile: {id: 1, age: 10, weight: 122, height: 164}})
        usr.set profile: {height: 180}
        expect(Profile.get(1).height).to.eq 180
        expect(usr.profile.height).to.eq 180

      it "should add resources already created", ->
        Profile.build id: 1, age: 10, weight: 122, height: 164, user_id: 5
        usr = User.build(id:5, name: 'Juan', email: 'juan@dogeater.com')
        expect(usr.profile.age).to.eq 10

      it "should add resources created outside with build", ->
        usr = User.build(id:6, name: 'Juan', email: 'juan@dogeater.com')
        Profile.build id: 1, age: 10, weight: 122, height: 164, user_id: 6
        expect(usr.profile.age).to.eq 10

      it "should add resources created outside with load", ->
        usr = User.build(id:7, name: 'Juan', email: 'juan@dogeater.com')
        Profile.load [{id: 1, age: 10, weight: 122, height: 164, user_id: 7}]
        expect(usr.profile.age).to.eq 10

      it "should not add resources on update if not persisted", ->
        usr = User.build(name: 'Juan', email: 'juan@dogeater.com')
        Profile.build id: 1, age: 10, weight: 122, height: 164, user_id: 8
        expect(usr.profile).to.be.undefined

    describe "destroy resource", ->
      it "should destroy dependant elements", ->
        Profile.build id: 1, age: 10, weight: 122, height: 164, user_id: 10
        usr = User.build(id:10, name: 'Juan', email: 'juan@dogeater.com')
        User.remove_by_id 10
        expect(Profile.get(1)).to.be.undefined

    describe "attributes", ->
      it "should serialize data correctly", ->
        usr = User.build(id:11, name: 'Juan', email: 'juan@dogeater.com')
        Profile.build id: 1, age: 10, weight: 122, height: 164, user_id: 11

        data = usr.attributes()
        expect(data.profile).to.have.keys ['id', 'age', 'weight', 'height']

    describe "reload after persist", ->
      it "should reload created associations", ->
        usr = User.build(name: 'Juan', email: 'juan@dogeater.com')
        Profile.build id: 1, age: 10, weight: 122, height: 164, user_id: 12

        usr.set id: 12

        expect(usr.profile.age).to.eq 10

    describe "events", ->
      it "should send update on has_one attached", ->
        usr = User.build(id: 13, name: 'Juan', email: 'juan@dogeater.com')
        usr.on 'update', (spy_fun = sinon.spy())

        Profile.build id: 1, age: 10, weight: 122, height: 164, user_id: 13

        expect(spy_fun.callCount).to.eq 1

      it "should send update on has_one updated", ->
        usr = User.build(id: 14, name: 'Juan', email: 'juan@dogeater.com', profile: {id: 2, age: 10, weight: 122, height: 164, user_id: 14})
        usr.on 'update', (spy_fun = sinon.spy())

        Profile.get(2).set height: 178

        expect(spy_fun.callCount).to.eq 1

      it "should send update on has_one destroyed", ->
        usr = User.build(id: 15, name: 'Juan', email: 'juan@dogeater.com', profile: {id: 3, age: 10, weight: 122, height: 164, user_id: 15})
        usr.on 'update', (spy_fun = sinon.spy())

        Profile.get(3).remove()

        expect(spy_fun.callCount).to.eq 1


