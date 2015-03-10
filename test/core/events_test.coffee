'use strict'
h = require 'pi/test/helpers'

describe "EventDispatcher", ->
  root_e = h.test_cont(pi.Nod.body)

  before ->
    h.mock_raf()

  after ->
    h.unmock_raf()
    root_e.remove()

  it "add native events and call handlers", ->
    test_div = h.test_cont root_e, """
      <div id='cont'>
        <button class='pi'>Button</button>
      </div>
        """
    el = test_div.find(".pi")

    spy = sinon.spy()

    el.on 'click', spy
    el.on 'click', spy

    h.clickElement el.node
    expect(spy.callCount).to.eq 2

  it "remove all events on off", ->
    test_div = h.test_cont root_e, """
      <div id='cont'>
        <button class='pi'>Button</button>
      </div>
        """
    el = test_div.find(".pi")
    spy_fun = sinon.spy()

    el.on 'click', spy_fun
    el.on 'mousedown', spy_fun
    expect(el.listeners).to.have.keys('click','mousedown')

    el.off()
    expect(el.listeners).to.eql({})

  it "not call removed events", ->
    test_div = h.test_cont root_e, """
      <div id='cont'>
        <button class='pi'>Button</button>
      </div>
        """
    el = test_div.find(".pi")
    
    spy_fun = sinon.spy()

    el.on 'click', spy_fun

    h.clickElement el.node
    el.off()

    h.clickElement el.node
    expect(spy_fun.callCount).to.eq 1

  it "remove native listener on off()", ->
    test_div = h.test_cont root_e, """
      <div id='cont'>
        <button class='pi'>Button</button>
      </div>
        """
    el = test_div.find(".pi")

    spy_native = sinon.spy(el,"add_native_listener")

    el.on "click", (event) => "hello"

    spy_fun = sinon.spy()

    el.on "click", spy_fun
    
    h.clickElement el.node
    
    el.off()
    
    h.clickElement el.node
    h.clickElement el.node
    
    expect(el.listeners).to.eql {}
    expect(spy_native.callCount).to.eq(1)
    expect(spy_fun.callCount).to.eq(1)


  it "remove native listener on off(event)", ->
    test_div = h.test_cont root_e, """
      <div id='cont'>
        <button class='pi'>Button</button>
      </div>
        """
    el = test_div.find(".pi")

    spy_native = sinon.spy(el,"add_native_listener")

    el.on "click", (event) => "hello"

    spy_fun = sinon.spy()

    el.on "click", spy_fun    

    h.clickElement el.node
    
    el.off 'click'
    
    h.clickElement el.node
    h.clickElement el.node
    
    expect(el.listeners.click).to.be.undefined
    expect(spy_native.callCount).to.eq(1)
    expect(spy_fun.callCount).to.eq(1)


  it "remove native listener on off(event,callback,context)", ->
    test_div = h.test_cont root_e, """
      <div id='cont'>
        <button class='pi'>Button</button>
      </div>
        """
    el = test_div.find(".pi")
    spy_native = sinon.spy(el,"add_native_listener")
    
    dummy =
      spy: sinon.spy()

    el.on "click", dummy.spy, dummy

    h.clickElement el.node
    
    el.off 'click', dummy.spy, dummy 
    
    h.clickElement el.node
    h.clickElement el.node

    expect(el.listeners.click).to.be.undefined
    expect(spy_native.callCount).to.eq(1)
    expect(dummy.spy.callCount).to.eq(1)

  it "call once if one(event)", ->
    test_div = h.test_cont root_e, """
      <div id='cont'>
        <button class='pi'>Button</button>
      </div>
        """
    el = test_div.find(".pi")
    
    dummy =
      spy: sinon.spy()

    el.one "click", dummy.spy, dummy

    h.clickElement el.node
    h.clickElement el.node
    h.clickElement el.node

    expect(dummy.spy.callCount).to.eq(1)

  it "remove native listener after event if one(event)", ->
    test_div = h.test_cont root_e, """
      <div id='cont'>
        <button class='pi'>Button</button>
      </div>
        """
    el = test_div.find '.pi'
    
    spy_native = sinon.spy(el,"add_native_listener")
    
    dummy =
      spy: sinon.spy()

    el.one "click", dummy.spy, dummy

    h.clickElement el.node
    h.clickElement el.node
    h.clickElement el.node

    expect(el.listeners.click).to.be.undefined
    expect(spy_native.callCount).to.eq(1)
    expect(dummy.spy.callCount).to.eq(1)


  it "work with several native events", ->
    test_div = h.test_cont root_e, """
      <div id='cont'>
        <button class='pi'>Button</button>
      </div>
        """
    el = test_div.find '.pi'
    
    spy_native = sinon.spy(el,"add_native_listener")
    spy_fun = sinon.spy()
    
    el.on "click, mouseover", spy_fun

    h.clickElement el.node
    
    el.off "click"

    h.mouseEventElement el.node, "mouseover"
    h.clickElement el.node

    expect(el.listeners.click).to.be.undefined
    expect(el.listeners.mouseover).to.have.length(1)
    expect(spy_native.callCount).to.eq(2)
    expect(spy_fun.callCount).to.eq(2)

  describe "aliases", ->
    afterEach ->
      delete pi.NodEvent.aliases.clicko
      delete pi.NodEvent.reversed_aliases.click

    it "work with alias", ->
      pi.NodEvent.register_alias 'clicko', 'click' 
      test_div = h.test_cont root_e, """
        <div id='cont'>
          <button class='pi'>Button</button>
        </div>
          """
      el = test_div.find '.pi'
      
      spy_fun = sinon.spy()
      spy_native = sinon.spy(el,"add_native_listener")

      el.on "clicko", spy_fun

      h.clickElement el.node
      expect(spy_fun.callCount).to.eq(1)
      expect(spy_native.callCount).to.eq(1)

  describe "Resize Delegate", ->
    afterEach ->
      pi.Nod.body.styles({height: null, width: null})

    it "trigger resize event if size changed", (done) ->
      example = h.test_cont root_e, """
          <div style="height: 50%; width: 200px;">
            <button class='pi'>Button</button>
          </div>
        """
      example.on "resize", (spy_fun = sinon.spy())

      pi.Nod.body.style('height','200px')
      h.resizeEvent()

      pi.utils.after 200, ->
        pi.Nod.body.style('height','200px')
        h.resizeEvent()
        expect(spy_fun.callCount).to.eq 1
        done()

    it "not trigger resize event if size haven't changed",  ->
      example = h.test_cont root_e, """
          <div style="height: 50%; width: 200px;">
            <button class='pi'>Button</button>
          </div>
      """
      example.on "resize", (spy_fun = sinon.spy())
      pi.Nod.body.style('width','200px')
      h.resizeEvent()
      expect(spy_fun.callCount).to.eq 0

    it "work with 'one'", (done) ->
      example = h.test_cont root_e, """
          <div style="height: 50%; width: 200px;">
            <button class='pi'>Button</button>
          </div>
      """
      example.one "resize", (spy_fun = sinon.spy())

      pi.Nod.body.style('height','150px')
      h.resizeEvent()

      pi.utils.after 400, (->
        pi.Nod.body.style('height','100px')
        h.resizeEvent()
        pi.utils.after 400, (->
          expect(spy_fun.callCount).to.eq 1
          done()
          )
        )