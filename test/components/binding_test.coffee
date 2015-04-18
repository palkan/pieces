'use strict'
h = require 'pieces-core/test/helpers'

describe "Binding", ->
  Nod = pi.Nod
  utils = pi.utils
  Binding = pi.bindings.Binding
  Testo = pi.resources.Testo
  Chef = pi.resources.Chef
  Eater = pi.Eater

  window.__bindme__ = {}
  window.__sum__ = (args...) ->
    acc = 0
    (acc+=(arg|0)) for arg in args
    acc

  root = Nod.create 'div'
  Nod.body.append root.node

  root = h.test_cont(pi.Nod.body)

  test_div = example = example2 = null

  after ->
    root.remove()
  
  describe "pure bindings", ->
    beforeEach  ->
      test_div = h.test_cont root, '''
      <div>
        <div class="pi test" data-pid="test" data-id="2">
          <div>John
            <input pid="input" type="text" class="pi" data-component="text_input"/>
            <span class="pi author"></span>
            <div class="pi block">
              <input pid="input" type="text" class="pi block-input" data-component="text_input"/>
            </div>
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

    afterEach ->
      Testo.clear_all()
      Testo.off()
      Chef.clear_all()
      Chef.off()
      Eater.clear_all()
      Eater.off()
      test_div.remove()

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

    it "binds simple property field", ->
      author = example.find('.author')
      new Binding(author, 'text', 'host.input.val.length')
      expect(author.text()).to.eq '0'
      example.input.value 'test123'
      expect(author.text()).to.eq '7'

    it "binds property within an object", ->
      author = example.find('.author')
      window.__bindme__.data =
        test: example.input 
      new Binding(author, 'text', '__bindme__.data.test.val.length')
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

    it 'binds complex expression (with several bindables) and only one exists', ->
      sum = example2.find('.sum')
      example2.input.remove()
      new Binding(sum, 'text', 'input.val + input2.val')
      expect(sum.text()).to.eq ''
      example2.input2.value '5'
      expect(sum.text()).to.eq ''
      example2.append '<input pid="input" type="text" class="pi" data-component="text_input" data-serialize="true"/>'
      example2.piecify()
      example2.input.value '3'
      expect(sum.text()).to.eq '8'

    it 'binds arguments', ->
      sum = example2.find('.sum')
      new Binding(sum, 'text', '__sum__(input.val,input2.val)')
      expect(sum.text()).to.eq '0'
      example2.input.value '3'
      expect(sum.text()).to.eq '3'
      example2.input2.value '5'
      expect(sum.text()).to.eq '8'

    it "disposed when target is disposed", ->
      author = example.find('.author')
      b = new Binding(author, 'text', 'host.input.val')
      expect(author.text()).to.eq ''
      example.input.value 'test123'
      example.remove()
      expect(b._disposed).to.be.true

    it "disposed when bindable is disposed", ->
      block = example.find('.block')
      b = new Binding(block, 'active', 'input.val')
      expect(block.active).to.be.false
      block.input.value 'test123'
      expect(block.active).to.be.true
      block.input.remove()
      expect(b._disposed).to.be.true

    it "binds resource", ->
      t = Testo.build(id: 1, name: 'Yeast')
      author = example.find('.author')
      new Binding(author, 'text', 'Testo(1).name')
      expect(author.text()).to.eq 'Yeast'
      t.set name: 'Drozzhi'
      expect(author.text()).to.eq 'Drozzhi'

    it "binds resource within object", ->
      t = Testo.build(name: 'Yeast')
      window.__bindme__.resto =
        test: t
      author = example.find('.author')
      new Binding(author, 'text', '__bindme__.resto.test.name')
      expect(author.text()).to.eq 'Yeast'
      t.set id: 1, name: 'Drozzhi'
      expect(author.text()).to.eq 'Drozzhi'

     it "binds resource view", ->
      author = example.find('.author')
      b = new Binding(author, 'buffer', "Testo(type: 'drozzhi')")
      spy = sinon.spy(b, 'update')
      expect(author.buffer.count()).to.eq 0
      
    it "binds resource view function", ->
      author = example.find('.author')
      b = new Binding(author, 'text', "Testo(type: 'drozzhi').count()")
      spy = sinon.spy(b, 'update')
      expect(author.text()).to.eq '0'
      
      t = Testo.build(id: 1, type: 'drozzhi')
      expect(author.text()).to.eq '1'
      expect(spy.callCount).to.eq 1

      Testo.build(type: 'yeast')
      expect(author.text()).to.eq '1'
      expect(spy.callCount).to.eq 1

      t.set(salty: 'little')
      expect(author.text()).to.eq '1'
      expect(spy.callCount).to.eq 2

      t.remove()
      expect(author.text()).to.eq '0'
      expect(spy.callCount).to.eq 3

  describe "DOM bindings", ->
    beforeEach  ->
      test_div = h.test_cont root, '''
      <div>
        <div class="pi test" data-pid="test" data-id="2">
          <div>John
            <input pid="input" type="text" class="pi" data-component="text_input"/>
            <span class="pi author" data-bind-text="host.input.val"></span>
            <span class="is-hidden pi alert" data-bind-visible="10 < host.input.val.length">Too long</span>
          </div>
        </div>
        <div class="pi test2" data-scoped="true" data-pid="test" data-id="2">
          <div>John
            <input pid="input" type="text" class="pi" data-component="text_input" data-serialize="true"/>
            <input pid="input2" type="text" class="pi" data-component="text_input" data-serialize="true"/>
            <span class="pi sum" data-bind-text="input.val + input2.val"></span>
          </div>
        </div>
      </div>'''
      pi.app.view.piecify()
      example = test_div.find('.test')
      example2 = test_div.find('.test2')

    afterEach ->
      test_div.remove()

    it "binds simple property", ->
      author = example.find('.author')
      expect(author.text()).to.eq ''
      example.input.value 'test123'
      expect(author.text()).to.eq 'test123'

    it "binds simple expression", ->
      alert = example.find('.alert')
      expect(alert.visible).to.be.false
      example.input.value 'test123'
      expect(alert.visible).to.be.false
      example.input.value '12345678901'
      expect(alert.visible).to.be.true
      example.input.value '123456789'
      expect(alert.visible).to.be.false

    it 'binds complex expression (with several bindables)', ->
      sum = example2.find('.sum')
      expect(sum.text()).to.eq ''
      example2.input.value '3'
      expect(sum.text()).to.eq '3'
      example2.input2.value '5'
      expect(sum.text()).to.eq '8'
