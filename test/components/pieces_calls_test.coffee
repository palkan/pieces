'use strict'
TestHelpers = require './helpers'

describe "pieces calls", ->
  Nod = pi.Nod
  root = Nod.create 'div'
  Nod.body.append root.node

  Compiler = pi.Compiler


  beforeEach ->
    @test_div = Nod.create 'div'
    @test_div.style position:'relative'
    root.append @test_div 
    TestHelpers.mock_raf()

  afterEach ->
    root.html ''
    TestHelpers.unmock_raf()

  describe "pi compiler", ->
    it "should detect simple args", ->
      expect(Compiler.is_simple_arg("23")).to.be.true
      expect(Compiler.is_simple_arg("'a3v'")).to.be.true
      expect(Compiler.is_simple_arg("@some")).to.be.false
      expect(Compiler.is_simple_arg("e.data")).to.be.false

    it "should create conditional function", ->
      dummy =
        up: ->
          @is_up = 1
        down: ->
          @is_up = 2

      fun = Compiler._conditional((-> true), dummy.up, dummy.down)
      fun.call dummy
      expect(dummy.is_up).to.eq 1

      fun = Compiler._conditional((-> false), dummy, dummy.down)
      fun.call dummy
      expect(dummy.is_up).to.eq 2

    it "should prepare simple arg", ->
      expect(Compiler.prepare_arg("123")).to.eq 123
      expect(Compiler.prepare_arg("false")).to.be.false
      expect(Compiler.prepare_arg("'testo'")).to.eq 'testo'

    it "should parse string (call without args)", ->
      res = Compiler.parse_str("app.kill.some")
      expect(res.target).to.eq 'app'
      expect(res.method_chain).to.eq 'kill.some'
      expect(res.args).to.have.length 0

    it "should parse string (call with 1 arg)", ->
      res = Compiler.parse_str("app.kill.some('human')")
      expect(res.target).to.eq 'app'
      expect(res.method_chain).to.eq 'kill.some'
      expect(res.args).to.have.length 1

    it "should parse string (call with 2 args)", ->
      res = Compiler.parse_str("app.kill.some(1,'human')")
      expect(res.target).to.eq 'app'
      expect(res.method_chain).to.eq 'kill.some'
      expect(res.args).to.have.length 2

    it "should parse string with sub-call", ->
      res = Compiler.parse_str("@app.update_section(1,e.data)")
      expect(res.target).to.eq '@app'
      expect(res.method_chain).to.eq 'update_section'
      expect(res.args).to.have.length 2

    it "should parse string with special symbols", ->
      res = Compiler.parse_str("@app.accept('image/pnf; charset=utf-8')")
      expect(res.target).to.eq '@app'
      expect(res.method_chain).to.eq 'accept'
      expect(res.args).to.have.length 1


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

    it "should work with call with multiple args", ->
      @test_div.find('.test2').append('''<span class="pi" pid="span2" data-on-click="@this.addClass('a','b')">abc</div>''')
      pi.app.view.piecify()
      TestHelpers.clickElement $('@test2').span2.node
      expect($('@test2').span2.hasClass('a')).to.be.true
      expect($('@test2').span2.hasClass('b')).to.be.true

    it "should work with call with multiple and nested args", ->
      @test_div.find('.test2').append('''<span class="pi" pid="span2" data-on-click="@this.addClass('a',e.type)">abc</div>''')
      pi.app.view.piecify()
      TestHelpers.clickElement $('@test2').span2.node
      expect($('@test2').span2.hasClass('a')).to.be.true
      expect($('@test2').span2.hasClass('click')).to.be.true

    it "should work with simple call with brackets", ->
      @test_div.find('.test2').append('''<span class="pi" pid="span2" data-on-click="@this.deactivate()">abc</div>''')
      pi.app.view.piecify()
      TestHelpers.clickElement $('@test2').span2.node
      expect($('@test2').span2.active).to.be.false



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