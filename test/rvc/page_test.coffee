'use strict'
TestHelpers = require './helpers'

describe "Pieces RVC", ->
  TestUsers = pi.resources.TestUsers
  Controller = pi.controllers.Base
  View = pi.TestView
  utils = pi.utils

  Nod = pi.Nod
  root = Nod.create 'div'
  Nod.body.append root.node

  page = pi.app.page

  describe "page test", ->

    beforeEach ->
      @test_div = Nod.create 'div'
      @test_div.style position:'relative'
      root.append @test_div 
      @test_div.append """
        <div class="pi" data-component="test_view" pid="test" style="position:relative">
          <div class="pi pi-progressbar" pid="loader"></div>
          <div class="pi pi-list-container" pid="list">
            <ul class="list">
            </ul>
          </div> 
        </div>
        <div class="pi" data-component="test2_view" pid="test" style="position:relative">
        </div>
      """

    afterEach ->
      @test_div.remove()
      page.dispose()
      TestUsers.clear_all()

    describe "initialization", ->

      it "should set contexts (without main)", (done) ->
        pi.app.initialize().then( =>
          expect(page.context).to.be.undefined
          expect(page._contexts['test']).to.be.instanceof Controller
          done()
        )

      it "should set contexts with main", (done) ->
        cont = $('.pi')
        cont.data('main',true)
        pi.app.initialize().then( =>
          expect(page.context).to.be.instanceof Controller
          expect(page._contexts['test']).to.be.instanceof Controller
          done()
        )

    describe "switching", ->

      beforeEach ->
        cont = $('.pi')
        cont.data('main',true)
        pi.app.initialize()
        @t = page._contexts.test
        @t2 = page._contexts.test2

      it "should switch to context", (done) ->
        pi.app.initialize().then(
          =>
            @t = page._contexts.test
            @t2 = page._contexts.test2
            expect(page.context_id).to.eq 'test'
            page.switch_to('test3').then( 
              (=>
                done('Error')),
              (=>
                done())
            )
        )

      it "should switch back in history", (done) ->
        pi.app.initialize().then(
          =>
            @t = page._contexts.test
            @t2 = page._contexts.test2
            page.switch_to('test2')
        ).then( 
          =>
            page.switch_to('test')
        ).then( 
          =>
            page.switch_to 'test2'
        ).then(
          =>
            page.switch_back()
        ).then(
          =>
            page.switch_back()
        ).then( 
          =>
            expect(page.context_id).to.eq 'test2'
            expect(page.context).to.eql @t2
            page.switch_to 'test'
        ).then(
          =>
            expect(page._history.size()).to.eq 2
            page.switch_back()
        ).then(
          =>
            page.switch_back()
        ).then(
          =>
            page.switch_to 'test2'
        ).then(
          =>
            expect(page._history.size()).to.eq 1
            done()
        )
  describe "page with nested controllers", ->
    beforeEach ->
      @test_div = Nod.create 'div'
      @test_div.style position:'relative'
      root.append @test_div 
      @test_div.append """
        <div class="pi" data-component="test_view" pid="test" data-main="true" style="position:relative">
          <div class="pi pi-progressbar" pid="loader"></div>
          <div class="pi pi-list-container" pid="list">
            <ul class="list">
            </ul>
          </div> 
          <div class="pi" data-component="test2_view" pid="test" data-main="true" style="position:relative">
        </div>
        </div>
      """

    afterEach ->
      @test_div.remove()
      page.dispose()
      TestUsers.clear_all()

    describe "initialization", ->
      it "should set contexts with main", (done) ->
        pi.app.initialize().then( =>
          expect(page.context).to.be.instanceof Controller
          expect(page._contexts['test']).to.be.instanceof Controller
          expect(page.context._contexts['test2']).to.be.instanceof Controller
          done()
        )