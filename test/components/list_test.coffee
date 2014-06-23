describe "list component", ->
  Nod = pi.Nod
  root = Nod.create 'div'
  Nod.root.append root.node

  beforeEach ->
    @test_div = Nod.create 'div'
    @test_div.style position:'relative'
    root.append @test_div 
    @test_div.append """
        <div class="pi" data-component="list" data-pi="test" style="position:relative">
          <ul class="list">
            <li class="item" data-id="1" data-key="one">One<span class="tags">killer,puppy</span></li>
            <li class="item" data-id="2" data-key="someone">Two<span class="tags">puppy, coward</span></li>
            <li class="item" data-id="3" data-key="anyone">Tre<span class="tags">bully,zombopuppy</span></li>
          </ul>
        </div>
      """
    pi.piecify()
    @list = $('@test')

  afterEach ->
    @test_div.remove()

  describe "list basics", ->
    it "should parse list items", ->
      expect(@list.size()).to.equal 3

    it "should add item", ->
      item = Nod.create('<li class="item" data-id="4" data-key="new">New</li>')
      @list.add_item item
      expect(@list.size()).to.equal 4
      expect($('@test').last('.item').text()).to.equal 'New'

    it "should add item at index", ->
      item = Nod.create('<li class="item" data-id="4" data-key="new">New</li>')
      @list.add_item_at item, 0
      expect(@list.size()).to.equal 4
      expect($('@test').first('.item').text()).to.equal 'New'

    it "should trigger update event on add", (done) ->
      item = Nod.create('<li class="item" data-id="4" data-key="new">New</li>')
      
      @list.on 'update', (event) =>
        expect(event.data.item.id).to.equal 4
        done()

      @list.add_item_at item, 0

    it "should remove element at", ->
      @list.remove_item_at 0
      expect(@list.size()).to.equal 2
      expect($('@test').first('.item').data('id')).to.equal '2'

    it "should clear all", ->
      @list.clear()
      expect($('@test').find('.item')).to.be.null

  describe "working with renderers", ->
    beforeEach ->
      @list.item_renderer = (data) ->
        nod = Nod.create("<div>#{ data.name }</div>")
        nod.addClass 'item'
        nod.append "<span class='author'>#{ data.author }</span>"
        data.nod = nod
        data
      return

    it "should set data provider with new rendered elements", ->
      @list.data_provider [ 
        {id:1, name: 'Element 1', author: 'John'},
        {id:2, name: 'Element 2', author: 'Bob'},
        {id:3, name: 'Element 3', author: 'John'} 
      ]
      expect(@list.all('.item').length).to.equal 3
      expect(@list.first('.author').text()).to.equal 'John'

  describe "item click and operations", ->
    it "should trigger correct item after list modification", (done) ->
      @list.remove_item_at 0

      @list.on 'item_click', (e) =>
        expect(e.data.item.id).to.equal 2
        done()

      TestHelpers.clickElement $("@test").first(".item").node

    it "should trigger correct item when click on child element", (done) ->

      @list.on 'item_click', (e) =>
        expect(e.data.item.id).to.equal 2
        done()

      TestHelpers.clickElement $("@test").find(".item:nth-child(2) .tags").node

  describe "list queries", ->
    it "should find by simple one-key object", ->
      item = @list.where(id:1)[0]
      expect(item.key).to.equal 'one'

    it "should find by object with string matcher", ->
      [item1, item2] = @list.where(key:'.+one')
      expect(item1.id).to.equal 2
      expect(item2.id).to.equal 3

    it "should find by simple string query", ->
      item = @list.where('Tre')[0]
      expect(item.key).to.equal 'anyone'

    it "should find by nested string query", ->
      [item1,item2] = @list.where('.tags:\\bpuppy\\b')
      expect(item1.key).to.equal 'one'
      expect(item2.key).to.equal 'someone'