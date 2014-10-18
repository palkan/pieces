'use strict'
TestHelpers = require '../helpers'

describe "jst renderer list plugin", ->
  Nod = pi.Nod
  root = Nod.create 'div'
  Nod.body.append root.node

  beforeEach ->
    @test_div = Nod.create 'div'
    @test_div.style position:'relative'
    root.append @test_div
    window.JST = {}

    window.JST['test/item'] = (data) ->
      nod = Nod.create("<div>#{ data.name }</div>")
      nod.addClass 'item'
      nod.append "<span class='author'>#{ data.author }</span>"
      nod  

    @test_div.append """
        <div class="pi" data-component="list" data-renderer="jst(test/item)"  data-pid="test" style="position:relative">
          <ul class="list">
          </ul>
        </div>
      """
    pi.app.view.piecify()

      

    @list = $('@test')

  afterEach ->
    @test_div.remove()

  describe "render template", ->
    
    it "should render elements with jst template", ->
      @list.data_provider [ 
        {id:1, name: 'Element 1', author: 'John'},
        {id:2, name: 'Element 2', author: 'Bob'},
        {id:3, name: 'Element 3', author: 'John'} 
      ]
      expect(@list.all('.item').length).to.equal 3
      expect(@list.first('.author').text()).to.equal 'John'
      expect(@list.items[2].html()).to.equal 'Element 3<span class="author">John</span>'