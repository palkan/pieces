'use strict'
TestHelpers = require './helpers'

describe "event dispatcher", ->
    Nod = pi.Nod
    root = Nod.create 'div'
    Nod.body.append root.node

    beforeEach  ->
      @test_div ||= Nod.create('div')
      @test_div.style position:'relative'
      root.append @test_div
      @test_div.append('<div class="pi" data-component="test_component" data-pid="test" style="position:relative"></div>')
      pi.app.initialize()

    afterEach ->
      @test_div.remove_children()


    it "should parse dom and add event handlers", ->
      @test_div.append """
        <div id='cont'>
          <button class='pi' data-component='base' data-pid='btn' data-on-click='@test.hide' data-on-custom='@test.show'>Button</button>
        </div>
          """
      pi.app.view.piecify()
      expect(pi.find("btn").listeners).to.have.keys(['click','custom'])

    it "should add native events and call handlers", ->
      @test_div.append """
        <div id='cont'>
          <button class='pi' data-component='base' data-pid='btn'>Button</button>
        </div>
          """
      pi.app.view.piecify()
      el = pi.find("btn")
      count = 0

      dummy =
        fn: -> true

      spy = sinon.spy(dummy,"fn")

      el.on 'click', dummy.fn, dummy
      el.on 'click', dummy.fn, dummy

      TestHelpers.clickElement el.node
      expect(spy.callCount).to.equal 2

    it "should add custom events and call handlers", ->
      @test_div.append """
        <div id='cont'>
          <button class='pi' data-component='base' data-pid='btn'>Button</button>
        </div>
          """
      pi.app.view.piecify()
      el = pi.find("btn")
      
      dummy =
        fn: -> true
        fn2: -> false

      spy = sinon.spy(dummy,"fn")
      spy2 = sinon.spy(dummy,"fn2")

      el.on 'enabled', dummy.fn, dummy
      el.on 'hidden', dummy.fn2, dummy

      el.hide()
      el.disable()

      expect(spy.callCount).to.equal 1
      expect(spy2.callCount).to.equal 1

    it "should remove all events on off", ->
      @test_div.append """
        <div id='cont'>
          <button class='pi' data-component='base' data-on-click='@test.hide' data-on-custom='@test.show' data-pid='btn'>Button</button>
        </div>
          """
      pi.app.view.piecify()
      el = pi.find("btn")
      el.off()
      expect(el.listeners).to.eql({})

    it "should not call removed events", (done)->
      @test_div.append """
        <div id='cont'>
          <button class='pi' data-component='base' data-on-click='@test.hide' data-on-custom='@test.show' data-pid='btn'>Button</button>
        </div>
          """
      pi.app.view.piecify()
      el = pi.find("btn")
      
      count = 0

      el.on 'enabled', (event) =>
        count.total++
      
      el.on 'click', (event) =>
        count.total++
      
      after 500, =>
        if count == 0
          done()

      el.off()
        
      TestHelpers.clickElement el.node
      el.disable()
      el.enable()

    it "should remove native listener on off()", ->
      @test_div.append """
        <div id='cont'>
          <button class='pi' data-component='base' data-pid='btn'>Button</button>
        </div>
          """
      pi.app.view.piecify()
      el = pi.find("btn")

      spy = sinon.spy(el,"add_native_listener")

      el.on "click", (event) => "hello"

      dummy =
        kill: -> true

      el.on "click", dummy.kill, dummy
      
      TestHelpers.clickElement el.node
      
      el.off()
      
      TestHelpers.clickElement el.node
      TestHelpers.clickElement el.node
      
      expect(el.listeners).to.eql {}
      expect(spy.callCount).to.equal(1)

    it "should remove native listener on off(event)", ->
      @test_div.append """
        <div id='cont'>
          <button class='pi' data-component='base' data-pid='btn'>Button</button>
        </div>
          """
      pi.app.view.piecify()
      el = pi.find('btn')

      spy = sinon.spy(el,"add_native_listener")

      el.on "click", (event) => "hello"

      dummy =
        kill: -> true

      el.on "click", dummy.kill, dummy     

      TestHelpers.clickElement el.node
      
      el.off 'click'
      
      TestHelpers.clickElement el.node
      TestHelpers.clickElement el.node
      
      expect(el.listeners.click).to.be.undefined
      expect(spy.callCount).to.equal(1)


    it "should remove native listener on off(event,callback,context)", ->
      @test_div.append """
        <div id='cont'>
          <button class='pi' data-component='base' data-pid='btn'>Button</button>
        </div>
          """
      pi.app.view.piecify()
      el = pi.find('btn')
      spy = sinon.spy(el,"add_native_listener")
      
      dummy =
        kill: -> pi.utils.debug('kill')

      el.on "click", dummy.kill, dummy

      TestHelpers.clickElement el.node
      
      el.off 'click', dummy.kill, dummy 
      
      TestHelpers.clickElement el.node
      TestHelpers.clickElement el.node

      expect(el.listeners.click).to.be.undefined
      expect(spy.callCount).to.equal(1)

    it "should call once if one(event)", ->
      @test_div.append """
        <div id='cont'>
          <button class='pi' data-component='base' data-pid='btn'>Button</button>
        </div>
          """
      pi.app.view.piecify()
      el = pi.find('btn')
      
      
      dummy =
        kill: -> pi.utils.debug('kill')

      spy = sinon.spy(dummy,"kill")

      el.one "click", dummy.kill, dummy

      TestHelpers.clickElement el.node
      TestHelpers.clickElement el.node
      TestHelpers.clickElement el.node

      expect(spy.callCount).to.equal(1)

    it "should handle multiple events", ->
      @test_div.append """
        <div id='cont'>
          <button class='pi' data-component='base' data-pid='btn'>Button</button>
        </div>
          """
      pi.app.view.piecify()
      el = pi.find('btn')
            
      dummy =
        kill: -> pi.utils.debug('kill')

      spy = sinon.spy(dummy,"kill")

      el.on "click,hidden,shown", dummy.kill, dummy

      TestHelpers.clickElement el.node
      el.hide()
      el.show()

      expect(spy.callCount).to.equal(3)

    it "should remove native listener after event if one(event)", ->
      @test_div.append """
        <div id='cont'>
          <button class='pi' data-component='base' data-pid='btn'>Button</button>
        </div>
          """
      pi.app.view.piecify()
      el = pi.find('btn')
      
      spy = sinon.spy(el,"add_native_listener")
      
      dummy =
        kill: -> pi.utils.debug('kill')

      el.one "click", dummy.kill, dummy

      TestHelpers.clickElement el.node
      TestHelpers.clickElement el.node
      TestHelpers.clickElement el.node

      expect(el.listeners.click).to.be.undefined
      expect(spy.callCount).to.equal(1)

    it "should work with several native events", ->
      @test_div.append """
        <div id='cont'>
          <button class='pi' data-component='base' data-pid='btn'>Button</button>
        </div>
          """
      pi.app.view.piecify()
      el = pi.find('btn')
      
      spy = sinon.spy(el,"add_native_listener")
      spy_fun = sinon.spy()
      
      el.on "click", spy_fun
      el.on "mouseover", spy_fun

      TestHelpers.clickElement el.node
      
      el.off "click"

      TestHelpers.mouseEventElement el.node, "mouseover"
      TestHelpers.clickElement el.node

      expect(el.listeners.click).to.be.undefined
      expect(el.listeners.mouseover).to.have.length(1)
      expect(spy.callCount).to.equal(2)
      expect(spy_fun.callCount).to.equal(2)
