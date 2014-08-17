TestHelpers = require './helpers'

describe "pieces calls", ->
  Nod = pi.Nod
  root = Nod.create 'div'
  Nod.body.append root.node

  beforeEach ->
    @test_div = Nod.create 'div'
    @test_div.style position:'relative'
    root.append @test_div 

  afterEach ->
    root.html ''

  
  describe "pi complex call queries", ->
    beforeEach  ->
      @test_div.append('<a class="pi" data-component="test_component" href="@this.text(@this.data(\'value\'))" data-value="13" data-pid="test1" style="position:relative">ping</a>')
      @test_div.append('<div class="pi test2" data-component="test_component" data-name="test2" data-pid="test2" style="position:relative"></div>')

      @test_div.append('<a id="call1" href="@test1.text(pong)">Text</div>')
      @test_div.append('<a id="call2" href="@test2.text(@test1.text)">Text</div>')
      @test_div.append('<a id="call3" href="@test2.btn.hide()">Hide</div>')
      @test_div.append('<a id="call4" href="@test1.text(ABC)">ABC</div>')
      @test_div.append('<a id="call5" href="@test1.addClass(\'A\',\'B\',\'is-dead\')">ABC</div>')
      @test_div.append('<a id="call6" href="@test1.addClass(@test2.name,\'B\')">ABC</div>')
      @test_div.find('.test2').append('<a class="pi" data-pid="btn" data-component="base" href="@test1.hide">Hide</div>')
      @test_div.find('.test2').append('<a class="pi" data-pid="btn2" data-component="base" href="@host.hide">Hide2</div>')
      pi.app.view.piecify()

    it "should work with nested component", ->
      TestHelpers.clickElement $('a#call3').node
      expect($('@test2').btn.visible).to.be.false

    it "should work with bound call", ->
      TestHelpers.clickElement $('a#call2').node
      expect($('@test2').text()).to.equal('ping')
      
      TestHelpers.clickElement $('a#call1').node
      TestHelpers.clickElement $('a#call2').node
      expect($('@test2').text()).to.equal('pong')

    it "should work with self bound call", ->
      TestHelpers.clickElement $('@test1').node
      expect($('@test1').text()).to.equal '13'

    it "should work with several args in call", ->
      TestHelpers.clickElement $('a#call5').node
      expect($('@test1').hasClass('A')).to.be.true
      expect($('@test1').hasClass('B')).to.be.true
      expect($('@test1').hasClass('is-dead')).to.be.true

    it "should work with several args and nested call", ->
      TestHelpers.clickElement $('a#call6').node
      expect($('@test1').hasClass('test2')).to.be.true
      expect($('@test1').hasClass('B')).to.be.true

    it "should work with call to host", ->
      TestHelpers.clickElement $('@test2').btn2.node
      expect($('@test2').visible).to.be.false

  describe "pi conditional calls", ->
    beforeEach  ->
      @test_div.append('''
        <div class="pi" data-pid="test" data-component="test_component">
          <span data-pid="result" class="pi"></span>
          <div class="pi is-disabled" id="c1" data-on-enabled="e.data ? @test.result.text('enabled') : @test.result.text('disabled')">ClickMe</div>
          <a id="c2" href="@test.enabled ? @test.disable : @test.enable">ClickMeToo</a>
        </div>
        ''')
      pi.app.view.piecify()
      @example = $("@test")

    it "should work with event condition", ->
      @example.c1.enable()
      expect(@example.result.text()).to.eq 'enabled'
      @example.c1.disable()
      expect(@example.result.text()).to.eq 'disabled'

    it "should work with bool condition", ->
      TestHelpers.clickElement $('a#c2').node
      expect(@example.enabled).to.be.false
      TestHelpers.clickElement $('a#c2').node
      expect(@example.enabled).to.be.true

    it "should work with greater condition", ->
      @example.append('<div class="pi" data-component="test_component" data-pid="c3" data-on-value="e.data>1 ? @this.show : @this.hide">ctest</div>')
      @example.piecify()
      @example.c3.value_trigger 1
      expect(@example.c3.visible).to.be.false
      @example.c3.value_trigger 2
      expect(@example.c3.visible).to.be.true

    it "should work with less condition", ->
      @example.append('<div class="pi" data-component="test_component" data-pid="c4" data-on-value="e.data<3 ? @this.show : @this.hide">ctest</div>')
      @example.piecify()
      @example.c4.value_trigger 5
      expect(@example.c4.visible).to.be.false
      @example.c4.value_trigger 2
      expect(@example.c4.visible).to.be.true

    it "should work with equality condition", ->
      @example.append('<div class="pi" data-component="test_component" data-pid="c5" data-on-value="e.data=2 ? @this.show : @this.hide">ctest</div>')
      @example.piecify()
      @example.c5.value_trigger 5
      expect(@example.c5.visible).to.be.false
      @example.c5.value_trigger 2
      expect(@example.c5.visible).to.be.true
      @example.c5.value_trigger 1
      expect(@example.c5.visible).to.be.false