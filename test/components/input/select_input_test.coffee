'use strict'
TestHelpers = require '../helpers'

describe "select_input component", ->
  Nod = pi.Nod
  root = Nod.create 'div'
  Nod.body.append root.node

  beforeEach ->
    @test_div = Nod.create 'div'
    @test_div.style position:'relative'
    root.append @test_div 
    @test_div.append """
        <div class="pi pi-select-field" data-pid="test" style="position:relative">
          <input type="hidden" value="2"/>
          <div class="pi placeholder" pid="placeholder" data-placeholder="Не выбрано"></div>
          <div class="pi pi-list is-hidden" data-pid="dropdown" style="position:relative">
            <ul class="list">
              <li class="item" data-value="1">One</li>
              <li class="item" data-value="2">Two</li>
              <li class="item" data-value="3">Tre</li>
            </ul>
          </div>
        </div>
        <button class="focus_me">focus</button>
      """
    pi.app.view.piecify()
    @example = $('@test')
    @list = @example.dropdown

  afterEach ->
    @test_div.remove()

  describe "init", ->
    it "should be select_input", ->
      expect(@example).to.be.instanceof pi.SelectInput

    it "should be init value", ->
      expect($('.placeholder').text()).to.eq 'Two'
      expect(@example.dropdown.selected_size()).to.eq 1

  describe "appearance", ->
    it "should show dropdown on focus", ->
      expect(@list.visible).to.be.false
      @example.trigger('focus')
      expect(@list.visible).to.be.true

    it "should hide dropdown on blur", (done) ->
      @example.trigger('focus')
      expect(@list.visible).to.be.true
      @example.trigger('blur')
      after 150, =>
        expect(@list.visible).to.be.false
        done()

  describe "show + click + hide", ->
    it "should show dropdown on focus",  (done) ->
      @example.on 'changed', (spy = sinon.spy())

      expect(@list.visible).to.be.false
      after 100, => @example.focus()
      after 200, =>
        expect(@list.visible).to.be.true
        TestHelpers.clickElement $('.pi-list .item').node
        expect($('.placeholder').text()).to.eq 'One'
        after 100, =>
          expect(@list.visible).to.be.false
          done()


  describe "events", ->
    it "should trigger change if item selected and update value", (done) ->
      @example.focus()
      @example.on pi.InputEvent.Change, (e) =>
        expect(e.data).to.eq 1
        expect($('.placeholder').text()).to.eq 'One'
        expect(@example.value()).to.eq '1'
        done()

      TestHelpers.clickElement $('.pi-list .item').node

  describe "set value", ->
    it "should update selection and placeholder", ->
      @example.value(2)
      expect($('.placeholder').text()).to.eq "Two"
      expect(@example.value()).to.eq '2'
      expect(@example.dropdown.selected_record().value).to.eq 2

  describe "clear", ->
    it "should clear selection and update placeholder", ->
      TestHelpers.clickElement $('.pi-list .item').node
      expect($('.placeholder').text()).to.eq 'One'

      @example.clear()
      expect($('.placeholder').text()).to.eq "Не выбрано"
      expect(@example.value()).to.eq ''
      expect(@example.dropdown.selected_size()).to.eq 0

    it "should clear selection and set default value", ->
      @example.options.default_value = 2
      TestHelpers.clickElement $('.pi-list .item').node
      expect($('.placeholder').text()).to.eq 'One'
      @example.clear()
      expect($('.placeholder').text()).to.eq "Two"
      expect(@example.value()).to.eq '2'
      expect(@example.dropdown.selected_size()).to.eq 1