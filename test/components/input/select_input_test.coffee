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
        <div class="pi pi-select-field" data-pid="test" data-on-change="@this.placeholder.text(e.data.key)" style="position:relative">
          <input type="hidden" value=""/>
          <div class="pi placeholder" pid="placeholder">Не выбрано</div>
          <div class="pi pi-list is-hidden" data-pid="dropdown" style="position:relative">
            <ul class="list">
              <li class="item" data-value="1" data-key="one">One</li>
              <li class="item" data-value="2" data-key="someone">Two</li>
              <li class="item" data-value="3" data-key="anyone">Tre</li>
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

  describe "appearance", ->
    it "should show dropdown on focus",  ->
      expect(@list.visible).to.be.false
      @example.focus()
      expect(@list.visible).to.be.true
      
    it "should hide dropdown on blur",  ->
      @example.focus()
      expect(@list.visible).to.be.true

      $('.focus_me').focus()

      expect(@list.visible).to.be.false

  describe "events", ->
    it "should trigger change if item selected and update value", (done) ->
      @example.focus()
      @example.on 'change', (e) =>
        expect(e.data.value).to.eq 1
        expect($('.placeholder').text()).to.eq 'one'
        expect(@example.value()).to.eq '1'
        done()

      TestHelpers.clickElement $('.pi-list .item').node