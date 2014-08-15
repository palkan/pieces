describe "Pieces RVC", ->
  TestUsers = pi.resources.TestUsers
  Controller = pi.controllers.Test
  View = pi.View.Test
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
        <div class="pi" data-component="view.test" pid="test" style="position:relative">
          <div class="pi pi-progressbar" pid="loader"></div>
          <div class="pi pi-list-container" pid="list">
            <ul class="list">
            </ul>
          </div> 
        </div>
        <div class="pi" data-component="view.test2" pid="test" style="position:relative">
        </div>
      """

    afterEach ->
      @test_div.remove()
      page.dispose()
      TestUsers.clear_all()

    describe "initialization", ->

      it "should set contexts (without main)", ->
        pi.app.initialize()
        expect(page.context).to.be.undefined
        expect(page._contexts['test']).to.be.instanceof Controller


      it "should set contexts with main", ->
        cont = $('.pi')
        cont.data('main',true)
        pi.app.initialize()
        expect(page.context).to.be.instanceof Controller
        expect(page._contexts['test']).to.be.instanceof Controller

    describe "switching", ->

      beforeEach ->
        cont = $('.pi')
        cont.data('main',true)
        pi.app.initialize()
        @t = page._contexts.test
        @t2 = page._contexts.test2

      it "should switch to context", ->
        expect(page.context_id).to.eq 'test'
        page.switch_to 'test2'
        expect(page.context_id).to.eq 'test2'
        expect(page.context).to.eql @t2
        expect(page._history.size()).to.eq 1

      it "should switch back in history", ->
        page.switch_to 'test2'
        page.switch_to 'test'
        page.switch_to 'test2'
        page.switch_back()
        page.switch_back()
        expect(page.context_id).to.eq 'test2'
        expect(page.context).to.eql @t2
        page.switch_to 'test'
        expect(page._history.size()).to.eq 2
        page.switch_back()
        page.switch_back()
        page.switch_to 'test2'
        expect(page._history.size()).to.eq 2