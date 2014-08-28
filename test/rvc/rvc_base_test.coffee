'use strict'
TestHelpers = require './helpers'

describe "Pieces RVC", ->
  TestUsers = pi.resources.TestUsers
  Controller = pi.controllers.Test
  utils = pi.utils

  Nod = pi.Nod
  root = Nod.create 'div'
  Nod.body.append root.node

  (window.JST||={})['test/user'] = (data) ->
    nod = Nod.create("<div>#{ data.name }</div>")
    nod.addClass 'item'
    nod.append "<span class='age'>#{ data.age }</span>"
    nod  

  page = pi.app.page

  describe "rvc base restful component", ->

    beforeEach ->
      @test_div = Nod.create 'div'
      @test_div.style position:'relative'
      root.append @test_div 

    afterEach ->
      @test_div.remove()
      page.dispose()
      TestUsers.clear_all()
      TestUsers.off()

    it "should bind app resource on init", (done) ->
      pi.app.user = TestUsers.build({name: 'Lee', age: 44})
      @test_div.append """
        <div class="pi" pid="test" data-plugins="restful" data-renderer="jst(test/user)" data-rest="app.user">
        </div>
      """
      pi.app.initialize()
      @example = $("@test") 
      after 100, =>
        expect(@example.restful.resource).to.eq pi.app.user
        done()

    it "should bind resource after init", ->
      @test_div.append """
        <div class="pi" pid="test" data-plugins="restful" data-renderer="jst(test/user)">
        </div>
      """
      pi.app.initialize()
      @example = $("@test") 

      pi.app.user = TestUsers.build({name: 'Lee', age: 44})
      @example.restful.bind pi.app.user, true
      expect(@example.find('.age').text()).to.eq '44'

      pi.app.user.set age: 45
      expect(@example.find('.age').text()).to.eq '45'

    it "should bind remote resource", (done) ->
      @test_div.append """
        <div class="pi" pid="test" data-plugins="restful" data-renderer="jst(test/user)" data-rest="TestUsers.find(2)">
        </div>
      """
      pi.app.initialize()
      @example = $("@test") 

      after 500, =>
        expect(@example.find('.age').text()).to.eq '12'
        TestUsers.get(2).set age: 13
        expect(@example.find('.age').text()).to.eq '13'
        done()

