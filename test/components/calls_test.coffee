'use strict'
h = require 'pieces-core/test/helpers'

describe "Calls", ->
  Nod = pi.Nod
  Compiler = pi.Compiler

  root = h.test_cont(pi.Nod.body)

  before ->
    h.mock_raf()

  after ->
    h.unmock_raf()
    root.remove()

 

  describe "complex calls", ->
    example = null
    test_div = null

    beforeEach  ->
      test_div = h.test_cont root
      test_div.append('<a class="pi test1" data-component="test_component" href="@this.text(@this.data(\'value\'))" data-value="13" data-pid="test1" style="position:relative">ping</a>')
      test_div.append('<div class="pi test2" data-component="test_component" data-name="test2" data-pid="test2" style="position:relative"></div>')

      test_div.append('<a id="call1" href="@test1.text(\'pong\')">Text</div>')
      test_div.append('<a id="call2" href="@test2.text(@test1.text())">Text</div>')
      test_div.append('<a id="call3" href="@test2.btn.hide()">Hide</div>')
      test_div.append('<a id="call4" href="@test1.text(\'ABC\')">ABC</div>')
      test_div.append('<a id="call5" href="@test1.addClass(\'A\',\'B\',\'is-dead\')">ABC</div>')
      test_div.append('<a id="call6" href="@test1.addClass(@test2.name(),\'B\')">ABC</div>')
      test_div.find('.test2').append('<a class="pi" data-pid="btn" data-component="base" href="@test1.hide()">Hide</div>')
      test_div.find('.test2').append('<a class="pi" data-pid="btn2" data-component="base" href="@host.hide()">Hide2</div>')
      pi.app.reinitialize()

    afterEach ->
      test_div.remove()

    it "with nested component", ->
      h.clickElement test_div.find('a#call3').node
      expect(test_div.find('.test2').btn.visible).to.be.false

    it "with bound call", ->
      h.clickElement test_div.find('a#call2').node
      expect(test_div.find('.test2').text()).to.equal('ping')
      
      h.clickElement test_div.find('a#call1').node
      h.clickElement test_div.find('a#call2').node
      expect(test_div.find('.test2').text()).to.equal('pong')

    it "with self bound call", ->
      h.clickElement test_div.find('.test1').node
      expect(test_div.find('.test1').text()).to.equal '13'

    it "swith several args in call", ->
      h.clickElement test_div.find('a#call5').node
      expect(test_div.find('.test1').hasClass('A')).to.be.true
      expect(test_div.find('.test1').hasClass('B')).to.be.true
      expect(test_div.find('.test1').hasClass('is-dead')).to.be.true

    it "with several args and nested call", ->
      h.clickElement test_div.find('a#call6').node
      expect(test_div.find('.test1').hasClass('test2')).to.be.true
      expect(test_div.find('.test1').hasClass('B')).to.be.true

    it "with call to host", ->
      h.clickElement test_div.find('.test2').btn2.node
      expect(test_div.find('.test2').visible).to.be.false

    it "with call with multiple args", ->
      test_div.find('.test2').append('''<span class="pi" pid="span2" data-on-click="@this.addClass('a','b')">abc</div>''')
      test_div.find('.test2').piecify()
      h.clickElement test_div.find('.test2').span2.node
      expect(test_div.find('.test2').span2.hasClass('a')).to.be.true
      expect(test_div.find('.test2').span2.hasClass('b')).to.be.true

    it "with call with multiple and nested args", ->
      test_div.find('.test2').append('''<span class="pi" pid="span2" data-on-click="@this.addClass('a',e.type)">abc</div>''')
      test_div.find('.test2').piecify()
      h.clickElement test_div.find('.test2').span2.node
      expect(test_div.find('.test2').span2.hasClass('a')).to.be.true
      expect(test_div.find('.test2').span2.hasClass('click')).to.be.true

    it "with simple call with brackets", ->
      test_div.find('.test2').append('''<span class="pi" pid="span2" data-on-click="@this.deactivate()">abc</div>''')
      test_div.find('.test2').piecify()
      h.clickElement test_div.find('.test2').span2.node
      expect(test_div.find('.test2').span2.active).to.be.false


  describe "conditionals", ->
    example = null
    test_div = null
    
    beforeEach  ->
      test_div = h.test_cont root, '''
        <div>
          <div class="pi conditionals" data-pid="test" data-component="test_component">
            <span data-pid="result" class="pi"></span>
            <div class="pi is-disabled" id="c1" data-on-enabled="e.data ? @test.result.text('enabled') : @test.result.text('disabled')">ClickMe</div>
            <a id="c2" href="@test.enabled ? @test.disable() : @test.enable()">ClickMeToo</a>
          </div>
        </div>
        '''
      pi.app.view.piecify()
      example = test_div.find('.conditionals')

    afterEach ->
      test_div.remove()

    it "with event condition", ->
      example.c1.enable()
      expect(example.result.text()).to.eq 'enabled'
      example.c1.disable()
      expect(example.result.text()).to.eq 'disabled'

    it "with bool condition", ->
      h.clickElement test_div.find('a#c2').node
      expect(example.enabled).to.be.false
      h.clickElement test_div.find('a#c2').node
      expect(example.enabled).to.be.true

    it "with greater condition", ->
      example.append('<div class="pi" data-component="test_component" data-pid="c3" data-on-value="e.data>1 ? @this.show() : @this.hide()">ctest</div>')
      example.piecify()
      example.c3.value_trigger 1
      expect(example.c3.visible).to.be.false
      example.c3.value_trigger 2
      expect(example.c3.visible).to.be.true

    it "with less condition", ->
      example.append('<div class="pi" data-component="test_component" data-pid="c4" data-on-value="e.data<3 ? @this.show() : @this.hide()">ctest</div>')
      example.piecify()
      example.c4.value_trigger 5
      expect(example.c4.visible).to.be.false
      example.c4.value_trigger 2
      expect(example.c4.visible).to.be.true

    it "with equality condition", ->
      example.append('<div class="pi" data-component="test_component" data-pid="c5" data-on-value="e.data=2 ? @this.show() : @this.hide()">ctest</div>')
      example.piecify()
      example.c5.value_trigger 5
      expect(example.c5.visible).to.be.false
      example.c5.value_trigger 2
      expect(example.c5.visible).to.be.true
      example.c5.value_trigger 1
      expect(example.c5.visible).to.be.false

  describe "call view", ->
    test_div = example = null

    beforeEach ->
      test_div = h.test_cont root, '''
        <div><div class="pi test" data-pid="test" data-controller="base">
          <span pid="btn" class="pi" data-on-click="@view.log.text('bla')"></span>
          <span pid="log" class="pi">loggo</span>
        </div></div>
        '''
      pi.app.view.piecify()
      example = test_div.find('.test')

    it "should work with view call", ->
      h.clickElement example.btn.node
      expect(example.log.text()).to.eq 'bla'

  describe "scoped", ->
    test_div = example = nested = null

    beforeEach ->
      test_div = h.test_cont root, '''
        <div>
          <div class="pi test" data-pid="test" data-scoped="true">
            <div class="pi controls" pid="controls">
              <div class="pi" pid="enable_btn" data-on-click="disable()"></div>
              <div class="pi" pid="subs_btn" data-on-click="subs.a.hide()"></div>
              <div class="pi message" pid="message">Message</div>
            </div>

            <div class="pi" pid="other_controls">
              <div class="pi" pid="hide_btn" data-on-click="message.hide()"></div>
              <div class="pi nested" pid="subs" data-scoped="true">
                <span class="pi a" pid="a" data-on-click="b.text('ABC')">A</span>
                <span class="pi b" pid="b" data-on-click="a.text('XYZ')">B</span>
              </div>
          </div>
        </div>
        '''
      pi.app.view.piecify()
      example = test_div.find('.test')
      nested = test_div.find('.nested')

    it "init scope", ->
      expect(example.scope.controls).to.not.be.undefined
      expect(example.scope.message).to.not.be.undefined
      expect(example.scope.subs_btn).to.not.be.undefined
      expect(example.scope.enable_btn).to.not.be.undefined
      expect(example.scope.other_controls).to.not.be.undefined
      expect(example.scope.subs).to.not.be.undefined
      expect(example.scope.subs.scope.a).to.not.be.undefined
      expect(example.scope.subs.scope.b).to.not.be.undefined

    it "call by pid", ->
      h.clickElement example.other_controls.hide_btn.node
      expect(example.find('.is-hidden')).to.eq example.controls.message

    it "call to host", ->
      h.clickElement example.controls.enable_btn.node
      expect(example.enabled).to.be.false

    it "call within nested scope", ->
      h.clickElement nested.a.node
      expect(nested.find('.b').text()).to.eq 'ABC'

      h.clickElement nested.b.node
      expect(nested.find('.a').text()).to.eq 'XYZ'

    it "call to nested scope", ->
      h.clickElement example.controls.subs_btn.node
      expect(nested.find('.is-hidden')).to.eq nested.a

    it "remove from scope", ->
      test_div.find('.message').remove()
      expect(example.scope.message).to.be.undefined

    it "remove from scope (with nested items)", ->
      test_div.find('.controls').remove()
      expect(example.scope.controls).to.be.undefined
      expect(example.scope.message).to.be.undefined
      expect(example.scope.subs_btn).to.be.undefined
      expect(example.scope.enable_btn).to.be.undefined

    it "remove from nested scope", ->
      test_div.find('.nested .a').remove()
      expect(nested.scope.a).to.be.undefined
