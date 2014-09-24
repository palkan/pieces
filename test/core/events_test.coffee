'use strict'
TestHelpers = require './helpers'

describe "event dispatcher", ->
    Nod = pi.Nod
    root = Nod.create 'div'
    Nod.body.append root.node

    beforeEach  ->
      @test_div = Nod.create 'div'
      @test_div.style position:'relative'
      root.append @test_div
      @test_div.append('<div style="position:relative"></div>')

    afterEach ->
      @test_div.remove()
      root.html ''


    it "should add native events and call handlers", ->
      @test_div.append """
        <div id='cont'>
          <button class='pi'>Button</button>
        </div>
          """
      el = pi.$(".pi")

      spy_fun = sinon.spy()

      el.on 'click', spy_fun
      el.on 'click', spy_fun

      TestHelpers.clickElement el.node
      expect(spy_fun.callCount).to.eq 2

    it "should remove all events on off", ->
      @test_div.append """
        <div id='cont'>
          <button class='pi'>Button</button>
        </div>
          """
      el = pi.$(".pi")
      spy_fun = sinon.spy()

      el.on 'click', spy_fun
      el.on 'mousedown', spy_fun
      expect(el.listeners).to.have.keys('click','mousedown')

      el.off()
      expect(el.listeners).to.eql({})

    it "should not call removed events", ->
      @test_div.append """
        <div id='cont'>
          <button class='pi'>Button</button>
        </div>
          """
      el = pi.$(".pi")
      
      spy_fun = sinon.spy()

      el.on 'click', spy_fun

      TestHelpers.clickElement el.node
      el.off()

      TestHelpers.clickElement el.node
      expect(spy_fun.callCount).to.eq 1

    it "should remove native listener on off()", ->
      @test_div.append """
        <div id='cont'>
          <button class='pi'>Button</button>
        </div>
          """
      el = pi.$(".pi")

      spy_native = sinon.spy(el,"add_native_listener")

      el.on "click", (event) => "hello"

      spy_fun = sinon.spy()

      el.on "click", spy_fun
      
      TestHelpers.clickElement el.node
      
      el.off()
      
      TestHelpers.clickElement el.node
      TestHelpers.clickElement el.node
      
      expect(el.listeners).to.eql {}
      expect(spy_native.callCount).to.eq(1)
      expect(spy_fun.callCount).to.eq(1)


    it "should remove native listener on off(event)", ->
      @test_div.append """
        <div id='cont'>
          <button class='pi'>Button</button>
        </div>
          """
      el = pi.$(".pi")

      spy_native = sinon.spy(el,"add_native_listener")

      el.on "click", (event) => "hello"

      spy_fun = sinon.spy()

      el.on "click", spy_fun    

      TestHelpers.clickElement el.node
      
      el.off 'click'
      
      TestHelpers.clickElement el.node
      TestHelpers.clickElement el.node
      
      expect(el.listeners.click).to.be.undefined
      expect(spy_native.callCount).to.eq(1)
      expect(spy_fun.callCount).to.eq(1)


    it "should remove native listener on off(event,callback,context)", ->
      @test_div.append """
        <div id='cont'>
          <button class='pi'>Button</button>
        </div>
          """
      el = pi.$(".pi")
      spy_native = sinon.spy(el,"add_native_listener")
      
      dummy =
        spy: sinon.spy()

      el.on "click", dummy.spy, dummy

      TestHelpers.clickElement el.node
      
      el.off 'click', dummy.spy, dummy 
      
      TestHelpers.clickElement el.node
      TestHelpers.clickElement el.node

      expect(el.listeners.click).to.be.undefined
      expect(spy_native.callCount).to.eq(1)
      expect(dummy.spy.callCount).to.eq(1)

    it "should call once if one(event)", ->
      @test_div.append """
        <div id='cont'>
          <button class='pi'>Button</button>
        </div>
          """
      el = pi.$(".pi")
      
      dummy =
        spy: sinon.spy()

      el.one "click", dummy.spy, dummy

      TestHelpers.clickElement el.node
      TestHelpers.clickElement el.node
      TestHelpers.clickElement el.node

      expect(dummy.spy.callCount).to.eq(1)

    it "should remove native listener after event if one(event)", ->
      @test_div.append """
        <div id='cont'>
          <button class='pi'>Button</button>
        </div>
          """
      el = pi.$ '.pi'
      
      spy_native = sinon.spy(el,"add_native_listener")
      
      dummy =
        spy: sinon.spy()

      el.one "click", dummy.spy, dummy

      TestHelpers.clickElement el.node
      TestHelpers.clickElement el.node
      TestHelpers.clickElement el.node

      expect(el.listeners.click).to.be.undefined
      expect(spy_native.callCount).to.eq(1)
      expect(dummy.spy.callCount).to.eq(1)


    it "should work with several native events", ->
      @test_div.append """
        <div id='cont'>
          <button class='pi'>Button</button>
        </div>
          """
      el = pi.$ '.pi'
      
      spy_native = sinon.spy(el,"add_native_listener")
      spy_fun = sinon.spy()
      
      el.on "click", spy_fun
      el.on "mouseover", spy_fun

      TestHelpers.clickElement el.node
      
      el.off "click"

      TestHelpers.mouseEventElement el.node, "mouseover"
      TestHelpers.clickElement el.node

      expect(el.listeners.click).to.be.undefined
      expect(el.listeners.mouseover).to.have.length(1)
      expect(spy_native.callCount).to.eq(2)
      expect(spy_fun.callCount).to.eq(2)

    describe "aliases", ->
      afterEach ->
        delete pi.NodEvent.aliases.clicko
        delete pi.NodEvent.reversed_aliases.click

      it "should work with alias", ->
        pi.NodEvent.register_alias 'clicko', 'click' 
        @test_div.append """
          <div id='cont'>
            <button class='pi'>Button</button>
          </div>
            """
        el = pi.$ '.pi'
        
        spy_fun = sinon.spy()
        
        el.on "clicko", spy_fun

        TestHelpers.clickElement el.node
        expect(spy_fun.callCount).to.eq(1)


    describe "resize delegate", ->
      beforeEach ->
        @test_div.append """
            <div id='flex' style="height: 50%; width: 200px;">
              <button class='pi'>Button</button>
            </div>
          """
        @example = $("#flex")

      afterEach ->
        pi.Nod.body.styles({height: null, width: null})

      it "should trigger resize event if size changed", (done) ->
        @example.on "resize", (spy_fun = sinon.spy())

        pi.Nod.body.style('height','200px')
        TestHelpers.resizeEvent()

        pi.Nod.body.style('height','200px')
        TestHelpers.resizeEvent()
        after 350, ->
          expect(spy_fun.callCount).to.eq 1
          done()

      it "should not trigger resize event if size haven't changed", (done) ->
        @example.on "resize", (spy_fun = sinon.spy())
        pi.Nod.body.style('width','200px')
        TestHelpers.resizeEvent()
        after 350, ->
          expect(spy_fun.callCount).to.eq 0
          done()

      it "should work with 'one'", (done) ->
        @example.one "resize", (spy_fun = sinon.spy())

        pi.Nod.body.style('height','200px')
        TestHelpers.resizeEvent()

        pi.Nod.body.style('height','100px')
        TestHelpers.resizeEvent()

        after 350, ->
          expect(spy_fun.callCount).to.eq 1
          done()