'use strict'
TestHelpers = require '../helpers'

describe "radio group component", ->
  Nod = pi.Nod
  root = Nod.create 'div'
  Nod.body.append root.node

  beforeEach ->
    @test_div = Nod.create 'div'
    @test_div.style position:'relative'
    root.append @test_div 
    @test_div.append """
        <div class="pi" data-component="radio_group" data-pid="test" style="position:relative">
          <input type="hidden" value="1"/>
          <ul class="list">
            <li class="item" data-value="1">1</li>
            <li class="item" data-value="2">2</li>
          </ul>
        </div>
      """
    pi.app.view.piecify()
    @test1 = $('@test')

  afterEach ->
    @test_div.remove()

  describe "initialize", ->
    it "should init value", ->
      expect(@test1.input.node.value).to.eq "1"
      expect(@test1.all('.is-selected')).to.have.length 1
      expect(@test1.value()).to.eq '1'
      expect(@test1.find('.is-selected').record.value).to.eq 1

  describe "click and events", ->
    it "should trigger event on item clicked", (done) ->
      @test1.on pi.InputEvent.Change, (e) =>
        expect(e.data).to.eq '2'
        expect(@test1.value()).to.eq '2'
        done()

      TestHelpers.clickElement @test1.find('[data-value="2"]').node

    it "should trigger event on clear", (done) ->
      @test1.on pi.InputEvent.Clear, (e) =>
        expect(@test1.value()).to.eq ''
        expect(@test1.selected_size()).to.eq 0
        done()

      @test1.clear()