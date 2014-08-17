'use strict'
TestHelpers = require './helpers'

describe "toggle_button component", ->
  Nod = pi.Nod
  root = Nod.create 'div'
  Nod.body.append root.node

  beforeEach ->
    @test_div = Nod.create 'div'
    @test_div.style position:'relative'
    root.append @test_div 

  afterEach ->
    root.empty()


  describe "selected event", ->
    beforeEach  ->
      @test_div.append('<div class="pi" data-pid="test" style="position:relative"></div>')
      @test_div.append('<button class="pi pi-toggle-button" pid="btn" data-on-selected="e.data ? @test.hide : @test.show" style="position:relative">Button</button>')
      pi.app.view.piecify()

    it "should trigger selected event", ->
      expect($('@test').visible).to.be.true

      TestHelpers.clickElement $('@btn').node
      expect($('@test').visible).to.be.false

      TestHelpers.clickElement $('@btn').node
      expect($('@test').visible).to.be.true