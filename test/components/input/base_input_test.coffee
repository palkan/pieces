'use strict'
TestHelpers = require '../helpers'

describe "base input component", ->
  Nod = pi.Nod
  root = Nod.create 'div'
  Nod.body.append root.node

  beforeEach ->
    @test_div ||= Nod.create('div')
    @test_div.style position:'relative'
    root.append @test_div 
    @test_div.append """
        <div class="pi" data-component="base_input" data-pid="test" style="position:relative">
          <input type="text" value="1"/>
        </div>
        <input class="pi" data-component="base_input"  data-pid="test2" type="text" value="2"/>
      """
    pi.app.view.piecify()
    @test1 = $('@test')
    @test2 = $('@test2')

  afterEach ->
    @test_div.remove_children()

  describe "base input", ->

    it "should init inputs", ->
      expect(@test1.input.node.value).to.eq "1"
      expect(@test1.value()).to.eq "1"
      expect(@test2.input).to.eq @test2
      expect(@test2.value()).to.eq "2" 

    it "should update value", ->
      @test1.value '123'
      expect(@test1.input.node.value).to.eq '123'
      @test2.value '234'
      expect(@test2.node.value).to.eq '234'

  describe "base input with serialize and default value", ->

    beforeEach ->
      @test_div.append """
        <input class="pi" data-component="base_input"  data-pid="test3" data-serialize="true" data-default-value="100" type="text" value=""/>
      """
      pi.app.view.piecify()
      @test3 = $('@test3')

    it "should init with default value", ->
      expect(@test3.input.node.value).to.eq "100"
      expect(@test3.value()).to.eq 100

    it "should update value", ->
      @test3.value '123'
      expect(@test3.input.node.value).to.eq '123'
      expect(@test3.value()).to.eq 123