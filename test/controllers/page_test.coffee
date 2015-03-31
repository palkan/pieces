'use strict'
h = require 'pieces-core/test/helpers'

TestUsers = pi.resources.TestUsers
Controller = pi.controllers.Base
utils = pi.utils
Nod = pi.Nod

pi.config.page = {default: 'test', strategy: 'one_by_one'}

describe "Page", ->
  root = h.test_cont(pi.Nod.body)

  after ->
    root.remove()

  page = null
  test_div = null

  beforeEach ->
    page = pi.app.page
    test_div = h.test_cont root, '''
      <div>
        <div class="pi" data-controller="test" pid="test" style="position:relative">
          <h2 class="pi" pid="title"></h2>
        </div>
        <div class="pi" data-view="test" data-controller="test2 | has_resource('test_users')" pid="test2" style="position:relative">
          <h2 class="pi" pid="title">Test2</h2>
          <div class="pi pi-list-container" pid="list">
            <ul class="list">
            </ul>
          </div>
        </div>
        <div class="pi" data-controller="test_preload" data-view="| loadable" pid="test3" style="position:relative">
          <div class="pi pi-progressbar" pid="loader"></div>
          <input class="pi" pid="input_txt"/>
        </div>
      </div>
    '''

  afterEach ->
    page.dispose()
    TestUsers.clear_all()

  describe "initialization", ->
    it "create controllers", (done) ->
      pi.app.reinitialize().then(
        ->
          expect(page.context).to.be.instanceof pi.controllers.Test
          expect(page._contexts['test']).to.eq page.context
          expect(page._contexts['test2']).to.be.instanceof pi.controllers.Test2
          expect(page._contexts['test3']).to.be.instanceof pi.controllers.TestPreload
          done()
      ).catch(done)

    it "create views", (done) ->
      pi.app.reinitialize().then(
        ->
          expect(page._contexts['test2'].view).to.be.instanceof pi.views.Test
          expect(page._contexts['test3'].view).to.be.instanceof pi.views.TestPreload
          done()
      ).catch(done)

    it "create modules", (done) ->
      pi.app.reinitialize().then(
        ->
          expect(page._contexts['test2'].resource).to.eq TestUsers
          expect(page._contexts['test3'].view.load).to.be.an 'function'
          done()
      ).catch(done)

  describe "switching", ->
    cont = t = tp = t2 = null

    it "switch to context with preload", (done) ->
      pi.app.reinitialize().then(
        ->
          t = page._contexts.test
          tp = page._contexts.test3
          expect(page.context_id).to.eq 'test'
          page.switch_to('test3').then( 
            ->
              expect(tp.preloaded).to.be.true
              done()
          )
      ).catch(done)

    it "switch to context", (done) ->
      pi.app.reinitialize().then(
        ->
          t = page._contexts.test
          t2 = page._contexts.test2
          expect(page.context_id).to.eq 'test'
          page.switch_to('test2')
      ).then( 
          ->
            expect(page.context_id).to.eq 'test2'
            expect(page.context).to.eql t2
            expect(page._history.size()).to.eq 2
            page.context.submit('i am test2')
      ).then( 
          ->
            expect(page.context).to.eql t
            expect(page.context.view.title.text()).to.eq 'i am test2'
            done()
      ).catch(done)

    it "fail if context is unknown", (done) ->
      pi.app.reinitialize().then(
        ->
          t = page._contexts.test
          t2 = page._contexts.test2
          expect(page.context_id).to.eq 'test'
          page.switch_to('test0').then( 
            (->
              done('Error')
            ),
            ->
              done()
          )
      ).catch(done)

    it "switch back and forth in history", (done) ->
      pi.app.reinitialize().then(
        ->
          t = page._contexts.test
          t2 = page._contexts.test2
          expect(page._history.size()).to.eq 1
          page.switch_to('test2')
      ).then( 
        ->
          expect(page._history.size()).to.eq 2
          page.switch_to('test')
      ).then( 
        ->
          expect(page._history.size()).to.eq 3
          page.switch_to 'test2'
      ).then(
        ->
          expect(page._history.size()).to.eq 4
          page.switch_back()
      ).then(
        ->
          expect(page._history.size()).to.eq 4
          page.switch_back()
      ).then( 
        ->
          expect(page._history.size()).to.eq 4
          expect(page.context_id).to.eq 'test2'
          expect(page.context).to.eql t2
          page.switch_to 'test'
      ).then(
        ->
          expect(page._history.size()).to.eq 3
          page.switch_back()
      ).then(
        ->
          page.switch_back()
      ).then(
        ->
          page.switch_to 'test2'
      ).then(
        ->
          expect(page._history.size()).to.eq 2
          done()
      ).catch(done)