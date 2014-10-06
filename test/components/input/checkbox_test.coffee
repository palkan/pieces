'use strict'
TestHelpers = require '../helpers'

describe "checkbox component", ->
  Nod = pi.Nod
  root = Nod.create 'div'
  Nod.body.append root.node

  beforeEach ->
    @test_div = Nod.create 'div'
    @test_div.style position:'relative'
    root.append @test_div 
    @test_div.append """
        <div class="pi pi-checkbox-wrap" data-pid="test" style="position:relative">
          <label>CheckBox</label>
          <input type="hidden" value="0"/>
        </div>
        <div class="pi pi-checkbox-wrap is-selected" data-pid="test2" style="position:relative">
          <label>CheckBox2</label>
          <input type="hidden" value="0"/>
        </div>
        <div class="pi pi-checkbox-wrap" data-pid="test3" style="position:relative">
          <label>CheckBox2</label>
          <input type="hidden" value="1"/>
        </div>
      """
    pi.app.view.piecify()
    @test1 = $('@test')
    @test2 = $('@test2')
    @test3 = $('@test3') 

  afterEach ->
    @test_div.remove()

  describe "init", ->

    it "should not be selected", ->
      expect(@test1.__selected__).to.be.false

    it "should be selected if class", ->
      expect(@test2.__selected__).to.be.true

    it "should be selected if value", ->
      expect(@test3.__selected__).to.be.true

  describe "update event", ->

    it "should trigger event on click", (done) ->
      @test1.on pi.InputEvent.Change, (e) =>
        expect(e.data).to.be.true
        expect(@test1.__selected__).to.be.true
        done()

      TestHelpers.clickElement @test1.find('label').node

    it "should update state on clicks",  ->
      TestHelpers.clickElement @test2.find('label').node
      expect(@test2.__selected__).to.be.false 
      TestHelpers.clickElement @test2.node
      expect(@test2.__selected__).to.be.true 

  describe "set value", ->
    it "should update state", ->
      @test2.value(true)
      expect(@test2.hasClass('is-selected')).to.be.true
      expect(@test2.value()).to.eq '1'
      expect(@test2.__selected__).to.be.true
      
  describe "clear", ->
    it "should clear state", ->
      @test2.clear()
      expect(@test2.hasClass('is-selected')).to.be.false
      expect(@test2.value()).to.eq '0'
      expect(@test2.__selected__).to.be.false

  describe "true and false values", ->
    beforeEach ->
      root.append @test_div 
      @test_div.append """
          <div class="pi pi-checkbox-wrap" data-default-value="a" data-true-value="a" data-false-value="b" data-pid="test4" style="position:relative">
            <label>CheckBox</label>
            <input type="hidden" value=""/>
          </div>
          <div class="pi pi-checkbox-wrap" data-default-value="c" data-true-value="b" data-false-value="c" data-pid="test5" style="position:relative">
            <label>CheckBox</label>
            <input type="hidden" value=""/>
          </div>
        """
      pi.app.view.piecify()
      @test4 = $('@test4')
      @test5 = $('@test5')

    it "should init default value as true", ->
      expect(@test4.__selected__).to.be.true
      expect(@test4.value()).to.eq 'a'
      expect(@test5.value()).to.eq 'c'
      expect(@test5.__selected__).to.be.false

    it "should set true and false values", ->
      expect(@test4.__selected__).to.be.true
      TestHelpers.clickElement @test4.find('label').node
      expect(@test4.value()).to.eq 'b'
      TestHelpers.clickElement @test4.find('label').node
      expect(@test4.value()).to.eq 'a'     