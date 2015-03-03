'use strict'
h = require 'pi/test/helpers'

describe "base input component", ->
  root = h.test_cont(pi.Nod.body)

  after ->
    root.remove()

  test1 = test2 = test_div = null

  beforeEach ->
    test_div = pi.Nod.create('div')
    test_div.style position:'relative'
    root.append test_div 
    test_div.append """
        <div class="pi test" data-component="base_input" data-pid="test" style="position:relative">
          <input type="text" value="1"/>
        </div>
        <input class="pi test2" data-component="base_input"  data-pid="test2" type="text" value="2"/>
      """
    pi.app.view.piecify()
    test1 = test_div.find('.test')
    test2 = test_div.find('.test2')

  afterEach ->
    test_div.remove()

  describe "base input", ->

    it "should init inputs", ->
      expect(test1.input.node.value).to.eq "1"
      expect(test1.value()).to.eq "1"
      expect(test2.input).to.eq test2
      expect(test2.value()).to.eq "2" 

    it "should update value", ->
      test1.value '123'
      expect(test1.input.node.value).to.eq '123'
      test2.value '234'
      expect(test2.node.value).to.eq '234'

  describe "base input with serialize and default value", ->
    test3 = null
    beforeEach ->
      test_div.append """
        <input class="pi test3" data-component="base_input"  data-pid="test3" data-serialize="true" data-default-value="100" type="text" value=""/>
      """
      pi.app.view.piecify()
      test3 = test_div.find('.test3')

    it "should init with default value", ->
      expect(test3.input.node.value).to.eq "100"
      expect(test3.value()).to.eq 100

    it "should update value", ->
      test3.value '123'
      expect(test3.input.node.value).to.eq '123'
      expect(test3.value()).to.eq 123