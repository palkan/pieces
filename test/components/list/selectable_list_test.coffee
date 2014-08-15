describe "selectable list plugin", ->
  Nod = pi.Nod
  root = Nod.create 'div'
  Nod.body.append root.node

  beforeEach ->
    @test_div = Nod.create 'div'
    @test_div.style position:'relative'
    root.append @test_div 
    @test_div.append """
        <div class="pi" data-component="list" data-plugins="selectable" data-pid="test" style="position:relative">
          <ul class="list">
            <li class="item" data-id="1" data-key="one">One<span class="tags">killer,puppy</span></li>
            <li class="item" data-id="2" data-key="someone">Two<span class="tags">puppy, coward</span></li>
            <li class="item" data-id="3" data-key="anyone">Tre<span class="tags">bully,zombopuppy</span></li>
          </ul>
        </div>
      """
    pi.app.view.piecify()
    @list = $('@test')

  afterEach ->
    @test_div.remove()

  describe "selectable list", ->

    it "should select one item when radio", (done)->
      
      TestHelpers.clickElement $('@test').find('[data-id="1"]').node

      @list.on 'item_click', (event) =>
        expect(@list.selected()[0].record.key).to.equal "anyone"
        done()

      TestHelpers.clickElement $('@test').find('[data-id="3"]').node

    it "should select several items when check", (done)->
      @list.selectable.type 'check'

      TestHelpers.clickElement $('@test').find('[data-id="1"]').node

      @list.on 'selected', (event) =>
        expect(@list.selected().length).to.equal 2
        expect(event.data.length).to.equal 2
        done()

      TestHelpers.clickElement $('@test').find('[data-id="3"]').node


    it "should select new item", (done)->
      item = Nod.create('<li class="item" data-id="4" data-key="new">New</li>')
      @list.add_item item

      @list.on 'selected', (event) =>
        expect(@list.selected()[0].record.key).to.equal 'new'
        expect(event.data[0].record.key).to.equal 'new'
        done()

      TestHelpers.clickElement $('@test').find('[data-id="4"]').node
      
    it "should send cleared event when all items are deselected", (done)->
      @list.selectable.type 'check'

      TestHelpers.clickElement $('@test').find('[data-id="1"]').node

      @list.on 'selection_cleared', (event) =>
        expect(@list.selected().length).to.equal 0
        done()

      TestHelpers.clickElement $('@test').find('[data-id="1"]').node

    it "should send cleared when selected item is removed", (done) ->
      TestHelpers.clickElement $('@test').find('[data-id="1"]').node

      @list.on 'selection_cleared', (event) =>
        expect(@list.selected().length).to.equal 0
        done()

      @list.remove_item_at 0

    it "should send cleared when list completely cleared", (done) ->
      TestHelpers.clickElement $('@test').find('[data-id="1"]').node

      @list.on 'selection_cleared', (event) =>
        expect(@list.selected().length).to.equal 0
        done()

      @list.clear()

    it "should not send cleared on item added", (done) ->

      @list.item_renderer = 
        render: (data) ->
          nod = Nod.create ("<div>#{ data.name }</div>")
          nod.addClass 'item'
          nod.append "<span class='author'>#{ data.author }</span>"
          pi.utils.extend nod,data
          nod

      @list.on 'selection_cleared', (event) =>
        expect(false).to.equal true
        done()

      after 1000, -> 
        done()

      @list.add_item {id:13, name: 'Element 3', author: 'John'} 