describe "filterable list plugin", ->
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
        <div class="pi" data-component="list" data-renderer="jst(test/item)" data-plugins="filterable" data-pid="test" style="position:relative">
          <ul class="list">
          </ul>
        </div>
      """
    pi.app.view.piecify()

    @list = $('@test')
    @list.data_provider [ 
        {id:1, age: 12, gender: 0, author: 'John', labels: [1,4,6]},
        {id:2, age: 20, gender: 1, author: 'Bob', labels: [1,2]},
        {id:3, age: 18, gender: 1, author: 'John', labels: [1,3,4]} 
        {id:3, age: 25, gender: 0, author: 'Michael', labels: [1,3,4]} 
      ]

  afterEach ->
    @test_div.remove()

  describe "list filters", ->
    
    it "should filter with one-key object", ->
      @list.filter gender: 0
      expect(@list.size()).to.equal 2
      @list.filter author: 'John'
      expect(@list.size()).to.equal 2

    it "should filter with continuation", ->
      @list.filter gender: 0
      expect(@list.size()).to.equal 2
      @list.filter author: 'John', gender: 0
      expect(@list.size()).to.equal 1

    it "should filter with more/less operands", ->
      @list.filter "age>": 20
      expect(@list.size()).to.equal 2
      @list.filter "age<": 20, gender: 0
      expect(@list.size()).to.equal 1
      @list.filter "age<": 20
      expect(@list.size()).to.equal 3

    it "should filter with any operand", ->
      @list.filter "author?": ['Bob','John']
      expect(@list.size()).to.equal 3
      @list.filter "author?": ['Bob','John'], gender: 1
      expect(@list.size()).to.equal 2
      @list.filter "gender?": [0,1]
      expect(@list.size()).to.equal 4

    it "should filter with contains operand", ->
      @list.filter "labels?&": [1,4]
      expect(@list.size()).to.equal 3
      @list.filter "labels?&": [2,3]
      expect(@list.size()).to.equal 0
      @list.filter "labels?&": [3,4]
      expect(@list.size()).to.equal 2

    it "should return all not-removed items on filter stop", ->
      @list.filter gender: 0
      expect(@list.size()).to.equal 2
      @list.remove_item_at 0
      expect(@list.size()).to.equal 1
      @list.filter() 
      expect(@list.size()).to.equal 3

