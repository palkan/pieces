'use strict'
h = require 'pieces-core/test/helpers'

describe "Base.Renderable", ->
  Nod = pi.Nod
  root = Nod.create 'div'
  Nod.body.append root.node

  root = h.test_cont(pi.Nod.body)

  test_div = example = null
  
  beforeEach  ->
    test_div = h.test_cont root, '''
    <div>
      <div class="pi test" data-pid="test" data-id="2">
        <div>John
          <span class="author">Green</span>
          <button class="pi" pid="some_btn">Button</button>
        </div>
        <script class="pi-renderer" type="text/html">
          {{ name }}
          <span class='author'>{{ author }}</span>
          <button class='pi' pid='some_btn'>Button</button>
        </script>
      </div>
    </div>'''
    pi.app.view.piecify()
    example = test_div.find('.test')

  afterEach ->
    test_div.remove()

  after ->
    root.remove()

  it "has render function", ->
    expect(example.render).to.be.an 'function'

  it "dispose old components and init new", ->
    old_btn = example.some_btn
    example.render name: 'Jack', author: 'Sparrow'

    expect(old_btn._disposed).to.be.true
    expect(example.find('.author').text()).to.eq 'Sparrow'
    expect(example.some_btn).to.be.an.instanceof $c.Base
    expect(example.__components__).to.have.length 1
    expect(example.some_btn).not.to.eq old_btn

  it "remove children if render null", ->
    old_btn = example.some_btn
    example.render null
    expect(old_btn._disposed).to.be.true
    expect(example.text()).to.eq ''
    expect(example.__components__).to.have.length 0
    expect(example.some_btn).to.be.undefined
