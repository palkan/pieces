'use strict'
h = require 'pieces-core/test/helpers'

describe "Binding", ->
  Nod = pi.Nod
  utils = pi.utils
  Binding = pi.components.Binding
  Testo = pi.resources.Testo

  root = Nod.create 'div'
  Nod.body.append root.node

  root = h.test_cont(pi.Nod.body)

  test_div = example = example2 = null
  
  beforeEach  ->
    test_div = h.test_cont root, '''
    <div>
      <div class="pi test" data-pid="test" data-id="2">
        <div>John
          <input pid="input" type="text" class="pi" data-component="text_input"/>
          <span class="pi author"></span>
        </div>
      </div>
      <div class="pi test2" data-scoped="true" data-pid="test" data-id="2">
        <div>John
          <input pid="input" type="text" class="pi" data-component="text_input" data-serialize="true"/>
          <input pid="input2" type="text" class="pi" data-component="text_input" data-serialize="true"/>
          <span class="pi sum"></span>
        </div>
      </div>
    </div>'''
    pi.app.view.piecify()
    example = test_div.find('.test')
    example2 = test_div.find('.test2')

  after ->
    root.remove()

  it "binds simple property on existent target", ->
    author = example.find('.author')
    new Binding(author, 'text', 'host.input.val')
    expect(author.text()).to.eq ''
    example.input.value 'test123'
    expect(author.text()).to.eq 'test123'

  it "binds simple property on unexistent target", ->
    example.input.remove()
    author = example.find('.author')
    new Binding(author, 'text', 'host.input.val')
    expect(author.text()).to.eq ''
    example.append '<input pid="input" type="text" class="pi" data-component="text_input"/>'
    example.piecify()
    example.input.value 'test123'
    expect(author.text()).to.eq 'test123'

  it "re-binds simple property on replaced target", (done) ->
    author = example.find('.author')
    new Binding(author, 'text', 'host.input.val')
    expect(author.text()).to.eq ''
    example.input.value 'test123'
    expect(author.text()).to.eq 'test123'
    example.input.remove()
    # binding invalidation occurs asynchronously
    utils.after 100, -> 
      expect(author.text()).to.eq ''
      example.append '<input pid="input" type="text" class="pi" data-component="text_input"/>'
      example.piecify()
      example.input.value 'xyz000'
      expect(author.text()).to.eq 'xyz000'
      done()

  xit "binds simple property field", ->
    author = example.find('.author')
    new Binding(author, 'text', 'host.input.val.length')
    expect(author.text()).to.eq '0'
    example.input.value 'test123'
    expect(author.text()).to.eq '7'

  it 'binds complex expression (with one bindable)', ->
    sum = example2.find('.sum')
    new Binding(sum, 'visible', 'input.val > 10')
    expect(sum.visible).to.be.false
    example2.input.value '3'
    expect(sum.visible).to.be.false
    example2.input.value '12'
    expect(sum.visible).to.be.true

  it 'binds complex expression (with several bindables)', ->
    sum = example2.find('.sum')
    new Binding(sum, 'text', 'input.val + input2.val')
    expect(sum.text()).to.eq ''
    example2.input.value '3'
    expect(sum.text()).to.eq '3'
    example2.input2.value '5'
    expect(sum.text()).to.eq '8'

  xit "binds resource", ->
    t = Testo.build(id: 1, name: 'Yeast')
    author = example.find('.author')
    new Binding(author, 'text', 'Testo(1).name')
    expect(author.text()).to.eq 'Yeast'
    t.set name: 'Drozzhi'
    expect(author.text()).to.eq 'Drozzhi'
    