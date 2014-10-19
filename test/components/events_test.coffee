'use strict'
h = require './helpers'

describe "event dispatcher", ->
  root = h.test_cont(pi.Nod.body)

  after ->
    root.remove()

  it "should parse dom and add event handlers", ->
    test_div = h.test_cont root, """
      <div id='cont'>
        <button class='pi' data-component='base' data-pid='btn' data-on-click='@test.hide' data-on-custom='@test.show'>Button</button>
      </div>
        """
    test_div=test_div.piecify()
    expect(test_div.btn.listeners).to.have.keys(['click','custom'])

  it "should add native events and call handlers", ->
    test_div = h.test_cont root, """
      <div id='cont'>
        <button class='pi' data-component='base' data-pid='btn'>Button</button>
      </div>
        """
    test_div=test_div.piecify()
    el = test_div.btn
    count = 0

    dummy =
      fn: -> true

    spy = sinon.spy(dummy,"fn")

    el.on 'click', dummy.fn, dummy
    el.on 'click', dummy.fn, dummy

    h.clickElement el.node
    expect(spy.callCount).to.equal 2

  it "should add custom events and call handlers", ->
    test_div = h.test_cont root, """
      <div id='cont'>
        <button class='pi' data-component='base' data-pid='btn'>Button</button>
      </div>
        """
    test_div=test_div.piecify()
    el = test_div.btn
    
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
    test_div = h.test_cont root, """
      <div id='cont'>
        <button class='pi' data-component='base' data-on-click='@test.hide' data-on-custom='@test.show' data-pid='btn'>Button</button>
      </div>
        """
    test_div=test_div.piecify()
    el = test_div.btn
    el.off()
    expect(el.listeners).to.eql({})

  it "should not call removed events", ->
    test_div = h.test_cont root, """
      <div id='cont'>
        <button class='pi' data-component='base' data-on-click='@test.hide' data-on-custom='@test.show' data-pid='btn'>Button</button>
      </div>
        """
    test_div=test_div.piecify()
    el = test_div.btn
    
    spy = sinon.spy()

    el.on 'enabled', spy
    
    el.on 'click', spy
    
    el.off()
      
    h.clickElement el.node
    el.disable()
    el.enable()
    expect(spy.callCount).to.eq 0

  it "should remove native listener on off()", ->
    test_div = h.test_cont root, """
      <div id='cont'>
        <button class='pi' data-component='base' data-pid='btn'>Button</button>
      </div>
        """
    test_div = test_div.piecify()

    el = test_div.btn

    spy = sinon.spy(el,"add_native_listener")

    el.on "click", (event) => "hello"

    dummy =
      kill: -> true

    el.on "click", dummy.kill, dummy
    
    h.clickElement el.node
    
    el.off()
    
    h.clickElement el.node
    h.clickElement el.node
    
    expect(el.listeners).to.eql {}
    expect(spy.callCount).to.equal(1)

  it "should remove native listener on off(event)", ->
    test_div = h.test_cont root, """
      <div id='cont'>
        <button class='pi' data-component='base' data-pid='btn'>Button</button>
      </div>
        """
    test_div=test_div.piecify()
    el = test_div.btn

    spy = sinon.spy(el,"add_native_listener")

    el.on "click", (event) => "hello"

    dummy =
      kill: -> true

    el.on "click", dummy.kill, dummy     

    h.clickElement el.node
    
    el.off 'click'
    
    h.clickElement el.node
    h.clickElement el.node
    
    expect(el.listeners.click).to.be.undefined
    expect(spy.callCount).to.equal(1)


  it "should remove native listener on off(event,callback,context)", ->
    test_div = h.test_cont root, """
      <div id='cont'>
        <button class='pi' data-component='base' data-pid='btn'>Button</button>
      </div>
        """
    test_div=test_div.piecify()
    el = test_div.btn
    spy = sinon.spy(el,"add_native_listener")
    
    dummy =
      kill: -> pi.utils.debug('kill')

    el.on "click", dummy.kill, dummy

    h.clickElement el.node
    
    el.off 'click', dummy.kill, dummy 
    
    h.clickElement el.node
    h.clickElement el.node

    expect(el.listeners.click).to.be.undefined
    expect(spy.callCount).to.equal(1)

  it "should call once if one(event)", ->
    test_div = h.test_cont root, """
      <div id='cont'>
        <button class='pi' data-component='base' data-pid='btn'>Button</button>
      </div>
        """
    test_div=test_div.piecify()
    el = test_div.btn
    
    
    dummy =
      kill: -> pi.utils.debug('kill')

    spy = sinon.spy(dummy,"kill")

    el.one "click", dummy.kill, dummy

    h.clickElement el.node
    h.clickElement el.node
    h.clickElement el.node

    expect(spy.callCount).to.equal(1)

  it "should handle multiple events", ->
    test_div = h.test_cont root, """
      <div id='cont'>
        <button class='pi' data-component='base' data-pid='btn'>Button</button>
      </div>
        """
    test_div=test_div.piecify()
    el = test_div.btn
          
    dummy =
      kill: -> pi.utils.debug('kill')

    spy = sinon.spy(dummy,"kill")

    el.on "click,hidden,shown", dummy.kill, dummy

    h.clickElement el.node
    el.hide()
    el.show()

    expect(spy.callCount).to.equal(3)

  it "should remove native listener after event if one(event)", ->
    test_div = h.test_cont root, """
      <div id='cont'>
        <button class='pi' data-component='base' data-pid='btn'>Button</button>
      </div>
        """
    test_div=test_div.piecify()
    el = test_div.btn
    
    spy = sinon.spy(el,"add_native_listener")
    
    dummy =
      kill: -> pi.utils.debug('kill')

    el.one "click", dummy.kill, dummy

    h.clickElement el.node
    h.clickElement el.node
    h.clickElement el.node

    expect(el.listeners.click).to.be.undefined
    expect(spy.callCount).to.equal(1)

  it "should work with several native events", ->
    test_div = h.test_cont root, """
      <div id='cont'>
        <button class='pi' data-component='base' data-pid='btn'>Button</button>
      </div>
        """
    test_div=test_div.piecify()
    el = test_div.btn
    
    spy = sinon.spy(el,"add_native_listener")
    spy_fun = sinon.spy()
    
    el.on "click", spy_fun
    el.on "mouseover", spy_fun

    h.clickElement el.node
    
    el.off "click"

    h.mouseEventElement el.node, "mouseover"
    h.clickElement el.node

    expect(el.listeners.click).to.be.undefined
    expect(el.listeners.mouseover).to.have.length(1)
    expect(spy.callCount).to.equal(2)
    expect(spy_fun.callCount).to.equal(2)
