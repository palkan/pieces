'use strict'
TestHelpers = require '../helpers'

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

  describe "rvc paginated list test", ->

    beforeEach ->
      @test_div ||= Nod.create('div')
      @test_div.style position:'relative'
      root.append @test_div 
      @test_div.append """
        <div class="pi" data-component="test_view" data-main="true" data-controller="test4" pid="test" style="position:relative">
          <div class="progress-wrapper">
            <div class="pi pi-progressbar" pid="loader"></div>
          </div>
          <div class="pi pi-action-list" data-renderer="jst(test/user)" data-plugins="restful" data-rest="test_users" pid="list">
            <ul class="list">
            </ul>
          </div> 
        </div>
      """
      pi.app.initialize()
      @t = page._contexts.test

    afterEach ->
      @test_div.remove_children()
      page.dispose()
      TestUsers.clear_all()
      TestUsers.off()

    describe "index paginated", ->
      it "should load by pages", (done) ->
        @t.index().then( =>
          expect(@t.view.list.size()).to.eq 5
          @t.next_page().then( =>
            expect(@t.view.list.size()).to.eq 10
            expect(TestUsers.all()).to.have.length 10
            done()
          )
        )

      it "should not load if all loaded", (done) ->
        @t.index().then( =>
          expect(@t.view.list.size()).to.eq 5
          @t.next_page().then( =>
            expect(@t.view.list.size()).to.eq 10
            @t.next_page().then( =>
              expect(@t.view.list.size()).to.eq 15
              expect(@t.next_page()).to.be.undefined
              done()
            )
          )
        )

      it "should not load if all loaded but request was queued", (done) ->
        @t.index().then( =>
          expect(@t.view.list.size()).to.eq 5
          spy_fun = sinon.spy(@t.resources, 'query')
          @t.next_page()
          @t.next_page()
          @t.next_page().then( (data) =>
            expect(data.users).to.have.length 5
            expect(spy_fun.callCount).to.eq 2
            expect(@t.view.list.size()).to.eq 15
            expect(@t.next_page()).to.be.undefined
            done()
          )
        ).catch( (e) => done(e))

    describe "query paginated", ->
      it "should search by pages", (done) ->
        @t.search('u').then( =>
          expect(@t.view.list.size()).to.eq 5
          @t.next_page().then( =>
            expect(@t.view.list.size()).to.eq 6
            expect(TestUsers.all()).to.have.length 6
            expect(@t.next_page()).to.be.undefined
            done()
          )
        )

    describe "index + search", ->
      it "should make request if scope is not full", (done) ->
        @t.sort([{age: 'desc'}]).then( =>
          expect(@t.view.list.size()).to.eq 5
          @t.search('u').then( =>
            expect(@t.view.list.size()).to.eq 5
            expect(TestUsers.all()).to.have.length 9
            expect(@t.view.list.items[0].record.name).to.eq 'hurry' 
            @t.sort([{age: 'asc'}]).then( =>
              expect(@t.view.list.size()).to.eq 5
              expect(TestUsers.all()).to.have.length 10
              expect(@t.view.list.items[0].record.name).to.eq 'luiza' 
              done()
            )
          )
        )