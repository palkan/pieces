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

  describe "rvc paginated list test", ->

    beforeEach ->
      @test_div = Nod.create 'div'
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
      @test_div.remove()
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
            expect(data).to.be.undefined
            expect(spy_fun.callCount).to.eq 2
            expect(@t.view.list.size()).to.eq 15
            expect(@t.next_page()).to.be.undefined
            @t.search('u').then(
              =>
                expect(@t.view.list.size()).to.eq 5
                @t.next_page()
                @t.next_page()
                @t.next_page().then( (data) =>
                  expect(data).to.be.undefined
                  expect(@t.view.list.size()).to.eq 6
                  done()
                )
            ) 
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
      beforeEach ->
        @t.scope_rules['q'] = 
          (prev,query) ->
            if query.match(prev)?.index == 0
              prev || ''
            else
              false
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

      it "should not make request if scope is full and was local", (done) ->
        @t.sort([{age: 'desc'}]).then( =>
          expect(@t.view.list.size()).to.eq 5
          @t.search('ur').then( =>
            expect(@t.view.list.size()).to.eq 2
            expect(@t.next_page()).to.be.undefined
            expect(@t.view.list.items[0].record.name).to.eq 'hurry' 
            @t.search('urt').then( =>
              expect(@t.view.list.size()).to.eq 1
              @t.search('ur').then( =>
                expect(@t.view.list.size()).to.eq 2
                expect(@t.next_page()).to.be.undefined
                expect(@t.view.list.items[0].record.name).to.eq 'hurry' 
                done()
              )
            )
          )
        )

      it "should not make request if scope is full and got debounce search calls", (done) ->
        spy_fun = sinon.spy(@t, '_resource_query')
        @t.search('ur')
        @t.search('urt')
        @t.search('urt wqeq')
        utils.after 1000, =>
          expect(spy_fun.callCount).to.eq 1
          done()

      it "should reload initial even if scope was full in beetween call series", (done) ->
        spy_fun = sinon.spy(@t, '_resource_query')
        @t.search('u')
        @t.search('urt')
        @t.search('u')
        @t.search('')
        utils.after 1000, =>
          expect(@t.view.list.size()).to.eq 5
          done()