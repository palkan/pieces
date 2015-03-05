'use strict'
h = require 'pi/test/helpers'

describe "Base.Renderable", ->
  Nod = pi.Nod
  root = Nod.create 'div'
  Nod.body.append root.node

  root = h.test_cont(pi.Nod.body)

  test_div = example = null
  
  beforeEach  ->
    window.JST ||= {}
    window.JST['test/base'] = (data) ->
      nod = Nod.create("<div>#{ data.name }</div>")
      nod.append "<span class='author'>#{ data.author }</span>"
      nod.append "<button class='pi' pid='some_btn'>Button</button>"
      nod  

    test_div = h.test_cont root, '''<div><div class="pi test" data-plugins="renderable" data-renderer="jst(test/base)" data-pid="test" data-id="2">
                        <div>John
                          <span class="author">Green</span>
                          <button class="pi" pid="some_btn">Button</button>
                        </div>
                      </div></div>'''
    pi.app.view.piecify()
    example = test_div.find('.test')

  afterEach ->
    test_div.remove()

  it "has render function", ->
    expect(example.render).to.be.an 'function'

  it "dispose old components and init new", ->
    old_btn = example.some_btn
    example.render name: 'Jack', author: 'Sparrow'

    expect(old_btn._disposed).to.be.true
    expect(example.text()).to.eq 'JackSparrowButton'
    expect(example.some_btn).to.be.an.instanceof pi.Base
    expect(example.__components__).to.have.length 1
    expect(example.some_btn).not.to.eq old_btn

  it "remove children if render null", ->
    old_btn = example.some_btn
    example.render null
    expect(old_btn._disposed).to.be.true
    expect(example.text()).to.eq ''
    expect(example.__components__).to.have.length 0
    expect(example.some_btn).to.be.undefined
