TestHelpers = require './helpers'

describe "button component", ->
  Nod = pi.Nod
  root = Nod.create 'div'
  Nod.body.append root.node

  beforeEach ->
    @test_div = Nod.create 'div'
    @test_div.style position:'relative'
    root.append @test_div 

  afterEach ->
    root.empty()
  
  describe "click option", ->
    beforeEach  ->
      @test_div.append('<div class="pi" data-pid="test" style="position:relative"></div>')
      @test_div.append('<button class="pi" data-component="button" data-pid="btn" data-on-click="@test.hide" style="position:relative">Button</button>')
      pi.app.view.piecify()

    it "should call method on click", ->
      TestHelpers.clickElement $('@btn').node
      expect($('@test').visible).to.be.false