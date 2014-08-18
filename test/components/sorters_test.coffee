'use strict'
TestHelpers = require './helpers'

describe "sorters component", ->
  Nod = pi.Nod
  root = Nod.create 'div'
  Nod.body.append root.node

  beforeEach ->
    @test_div = Nod.create 'div'
    @test_div.style position:'relative'
    root.append @test_div 
    @test_div.append '''
        <div class="pi pi-sorters" data-pid="test" style="position:relative">
          <span pid="sorters[]" data-name="a" class="pi">a</span>
          <span pid="sorters[]" data-name="b" class="pi is-desc">b</span>
        </div>
        '''
    pi.app.view.piecify()
    @example = $('@test')

  afterEach ->
    root.empty()
  
  describe "initialization", ->
    it "should init as Sorters", ->
      expect(@example).to.be.an.instanceof pi.Sorters

    it "should init sorters", ->
      expect(@example.sorters).to.have.length 2

    it "should init value", ->
      expect(@example.value()[0].b).to.eq 'desc'


  describe "update events", ->
    it "should dispatch update on sorter click", (done) ->
      @example.on 'update', (e) =>
        expect(e.data[0].b).to.eq 'asc'
        done()

      TestHelpers.clickElement @example.last('.pi').node

    it "should dispatch update on every click with multiple set to true", ->
      @example.options.multiple = true

      TestHelpers.clickElement @example.last('.pi').node
      expect(@example.value()).to.have.length 0
      TestHelpers.clickElement @example.first('.pi').node
      TestHelpers.clickElement @example.first('.pi').node
      expect(@example.value()).to.have.length 1
      TestHelpers.clickElement @example.last('.pi').node
      expect(@example.value()).to.have.length 2
      expect(@example.value()[0].a).to.eq 'desc'
      expect(@example.value()[1].b).to.eq 'asc'

  describe "set", ->
    it "should set values and update classes", ->
      @example.set [{a: 'asc'}]
      expect(@example.value()).to.have.length 1
      expect(@example.all('.is-asc')).to.have.length 1
      expect(@example.all('.is-desc')).to.have.length 0