describe "list component", ->
  beforeEach ->
    @test_div = $(document.createElement('div'))
    @test_div.css position:'relative'
    $('body').append(@test_div)
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
    @list = $('@test').pi()

  afterEach ->
    @test_div.remove()

  describe "list basics", ->
    it "should parse list items", ->
      expect(@list.size()).to.equal 3

    it "should add item", ->
      item = $('<li class="item" data-id="4" data-key="new">New</li>')
      @list.add_item item
      expect(@list.size()).to.equal 4
      expect($('@test .item').last().text()).to.equal 'New'

    it "should add item at index", ->
      item = $('<li class="item" data-id="4" data-key="new">New</li>')
      @list.add_item_at item, 0
      expect(@list.size()).to.equal 4
      expect($('@test .item').first().text()).to.equal 'New'

    it "should trigger update event on add", (done) ->
      item = $('<li class="item" data-id="4" data-key="new">New</li>')
      
      @list.on 'update', (event) =>
        expect(event.data.item.id).to.equal 4
        done()

      @list.add_item_at item, 0

    it "should remove element at", ->
      @list.remove_item_at 0
      expect(@list.size()).to.equal 2
      expect($('@test .item').first().data('id')).to.equal 2

    it "should clear all", ->
      @list.clear()
      expect($('@test .item').size()).to.equal 0

  describe "working with renderers", ->
    beforeEach ->
      @list.item_renderer = (data) ->
        nod = $("<div>#{ data.name }</div>")
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
      expect(@list.nod.find('.item').size()).to.equal 3
      expect(@list.nod.find('.author').first().text()).to.equal 'John'


  describe "list queries", ->
    it "should find by simple one-key object", ->
      item = @list.find(id:1)[0]
      expect(item.key).to.equal 'one'

    it "should find by object with string matcher", ->
      [item1, item2] = @list.find(key:'.+one')
      expect(item1.id).to.equal 2
      expect(item2.id).to.equal 3

    it "should find by simple string query", ->
      item = @list.find('Tre')[0]
      expect(item.key).to.equal 'anyone'

    it "should find by nested string query", ->
      [item1,item2] = @list.find('.tags:\\bpuppy\\b')
      expect(item1.key).to.equal 'one'
      expect(item2.key).to.equal 'someone'