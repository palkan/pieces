'use strict'
h = require 'pieces-core/test/helpers'

describe "TextInput", ->
  root = h.test_cont(pi.Nod.body)

  after ->
    root.remove()

  test_div = test1 = test2 = null

  beforeEach ->
    test_div = pi.Nod.create('div')
    test_div.style position:'relative'
    root.append test_div 
    test_div.append """
        <div class="pi test" data-component="text_input" data-pid="test" style="position:relative">
          <input type="text" value="1"/>
        </div>
        <input class="pi is-readonly test2" data-component="text_input" data-pid="test2" type="text" value="2"/>
      """
    pi.app.view.piecify()
    test1 = test_div.find('.test')
    test2 = test_div.find('.test2')

  afterEach ->
    test_div.remove()

  describe "editable", ->

    it "trigger event on readonly", (done) ->
      test1.on 'editable', (e) =>
        expect(e.data).to.be.false
        expect(test1.editable).to.be.false
        done()

      test1.readonly()

    it "init as readonly", ->
      expect(test2.editable).to.be.false

    it "trigger event on edit", (done) ->
      test2.on 'editable', (e) =>
        expect(e.data).to.be.true
        expect(test2.editable).to.be.true
        done()

      test2.readonly(false)
      