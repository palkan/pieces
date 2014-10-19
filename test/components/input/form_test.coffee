'use strict'
h = require '../helpers'

describe "form component", ->
  root = h.test_cont(pi.Nod.body)

  after ->
    root.remove()

  test_div = null

  beforeEach ->
    test_div = pi.Nod.create('div')
    test_div.style position:'relative'
    root.append test_div 

  afterEach ->
    test_div.remove()

  describe "initialize", ->
    example = null
    beforeEach ->
      test_div.append """
        <form class="pi test" data-component="form" data-pid="test">
          <input name="desc" type="text" value="1"/>
          <input  name="title" type="text" value="Title"/>
          <label for="is_active">CheckBox</label>
          <input type="checkbox" name="is_active" value="1"/>
          <select name="type">
              <option value="1">One</option>
              <option value="2" selected>Two</option>
              <option value="3">Tre</option>
          </select>
          <button type="submit">Submit</button>
        </form>
      """
      pi.app.view.piecify()
      example = test_div.find('.test')

    it "should be Form", ->
      expect(example).to.be.an.instanceof pi.Form

    it "should init value", ->
      expect(example.value().desc).to.eq '1'
      expect(example.value().is_active).to.eq null
      expect(example.value().type).to.eq '2'
      expect(example.value().title).to.eq 'Title'

    it "should cache inputs by name", ->
      expect(example.find_by_name('desc').value()).to.eq '1'
      expect(example.find_by_name('is_active').node.checked).to.be.false

    it "should find new inputs by name", ->
      example.append '''<textarea type="text" name="comment">Good news everyone!</textarea>'''
      expect(example.find_by_name('comment').value()).to.eq 'Good news everyone!'

  describe "inputs update", ->
    example = null
    beforeEach ->
      test_div.append """
        <form class="pi test" data-component="form" data-pid="test">
          <div id="desc" class="pi" data-component="text_input" data-name="desc" data-pid="test" style="position:relative">
            <input type="text" value="1"/>
          </div>
          <input id="title" name="title" type="text" value="Title"/>
          <label for="is_active">CheckBox</label>
          <input id="is_active" type="checkbox" name="is_active" value="1"/>
          <select name="type" id="type">
              <option value="1">One</option>
              <option value="2">Two</option>
              <option value="3">Tre</option>
          </select>
          <button type="submit">Submit</button>
        </form>
      """
      pi.app.view.piecify()
      example = test_div.find('.test')
    
    it "should handle native inputs updates", (done) ->
      example.on pi.FormEvent.Update, (e) =>
        expect(example.value().title).to.eq 'any'
        expect(e.data.title).to.eq 'any'
        done()
      test_div.find("#title").value 'any'
      h.changeElement test_div.find("#title").node

    it "should handle BaseInputs updates", (done) ->
      example.on pi.FormEvent.Update, (e) =>
        expect(example.value().desc).to.eq 'long description'
        expect(e.data.desc).to.eq 'long description'
        done()

      test_div.find("#desc input").value 'long description'
      h.changeElement test_div.find("#desc input").node

    it "should set inputs values", ->
      example.value desc: 'Song', title: 'EA', is_active: true, type: 3, bull: 'shit' 
      
      expect(test_div.find("#desc").value()).to.eq 'Song'
      expect(test_div.find("#title").value()).to.eq 'EA'
      expect(test_div.find("#is_active").node.checked).to.be.true
      expect(test_div.find("#type option:nth-child(3)").node.selected).to.be.true

      val = example.value()
      expect(val.desc).to.eq 'Song'
      expect(val.title).to.eq 'EA'
      expect(val.is_active).to.eq '1'
      expect(val.type).to.eq '3'
      expect(val).to.have.keys ['desc', 'title', 'is_active', 'type']

    it "should clear inputs values", ->
      example.clear()
      
      expect(test_div.find("#desc").value()).to.eq ''
      expect(test_div.find("#title").value()).to.eq ''
      expect(test_div.find("#is_active").node.checked).to.be.false
      expect(test_div.find("#type option:nth-child(3)").node.selected).to.be.false
      expect(test_div.find("#type option:nth-child(2)").node.selected).to.be.false
      expect(test_div.find("#type option:nth-child(1)").node.selected).to.be.true # by default select element select first option