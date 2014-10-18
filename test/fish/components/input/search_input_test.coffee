'use strict'
TestHelpers = require '../../helpers'

describe "search_input component", ->
  Nod = pi.Nod
  root = Nod.create 'div'
  Nod.body.append root.node

  beforeEach ->
    @test_div = Nod.create 'div'
    @test_div.style position:'relative'
    root.append @test_div 
    @test_div.append """
        <div class="pi pi-search-field" data-pid="test" data-on-query="@list.search(e.data)" style="position:relative">
          <input type="text" value=""/>
        </div>
        <div class="pi pi-action-list" data-pid="list" style="position:relative">
          <ul class="list">
            <li class="item" data-id="1" data-key="one">One</li>
            <li class="item" data-id="2" data-key="someone">Two</li>
            <li class="item" data-id="3" data-key="anyone">Tre</li>
          </ul>
        </div>
      """
    pi.app.view.piecify()
    @example = $('@test')
    @list = $('@list')

  afterEach ->
    @test_div.remove()

  describe "init", ->
    it "should be search_input", ->
      expect(@example).to.be.instanceof pi.SearchInput

  describe "query event", ->
    it "should send query event with correct query on input change", (done) ->
      @example.on 'query', (e) =>
        expect(e.data).to.eq 'T'
        expect(@list.size()).to.eq 2
        done()

      @example.input.value('T').trigger('keyup')

    it "should debounce query event", (done) ->
      spy_fun = sinon.spy()
    
      @example.on 'query', spy_fun

      after 400, =>
        expect(spy_fun.callCount).to.eq 2
        expect(@list.size()).to.eq 0
        done()

      @example.input.value('T').trigger('keyup')
      @example.input.value('Tr').trigger('keyup')
      @example.input.value('Tres').trigger('keyup')

