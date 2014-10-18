'use strict'
TestHelpers = require '../../helpers'


describe "file input component", ->
  Nod = pi.Nod
  root = Nod.create 'div'
  Nod.body.append root.node

  beforeEach ->
    test_div = Nod.create('div')
    test_div.style position:'relative'
    root.append test_div 
    test_div.append """
        <div class="pi button pi-file-input-wrap" pid="test" style="position:relative">
          <input type="file" multiple/>
        </div>
      """
    pi.app.view.piecify()
    @test1 = $('@test')

  afterEach ->
    @test1.remove()

  describe "guess type", ->
    it "should guess as file_input", ->
      expect(@test1).to.be.instanceof pi.FileInput
