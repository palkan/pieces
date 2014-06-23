describe "drag-selectable list component", ->
  Nod = pi.Nod
  root = Nod.create 'div'
  Nod.root.append root.node

  beforeEach ->
    @test_div = Nod.create 'div'
    @test_div.style position:'relative'
    root.append @test_div 
    @test_div.append """
        <div class="pi" data-component="list" data-plugins="selectable drag_select" data-pi="test" data-options-select="check" style="position:relative">
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

  describe "selectable list with dragging select support", ->

    it "should select one item on mousedown", (done)->
      
      @list.on 'selected', (event) =>
        expect(@list.selected()[0].key).to.equal "anyone"
        done()

      item = $('@test').find('[data-id="3"]')

      TestHelpers.mouseEventElement item.node, 'mousedown', (item.x()+10), (item.y()+10)

    it "should select all elements on drag", (done) ->
      
      item1 = $('@test').find('[data-id="1"]')
      item2 = $('@test').find('[data-id="2"]')
      item3 = $('@test').find('[data-id="3"]')

      TestHelpers.mouseEventElement item1.node, 'mousedown', (item1.x()+10), (item1.y()+10)
      after 400, ->
        TestHelpers.mouseEventElement item2.node, 'mousemove', (item2.x()+5), item2.y()
      after 500, ->
        TestHelpers.mouseEventElement item3.find('.tags').node, 'mousemove', (item3.x()+2), (item3.y()+2)
      after 900, ->
        TestHelpers.mouseEventElement item3.find('.tags').node, 'mouseup'

      after 1000, =>
        expect(@list.selected()[0].key).to.equal "one"
        expect(@list.selected().length).to.equal 3
        done()


    it "should select all elements on drag thru", (done) ->
      
      item1 = $('@test').find('[data-id="1"]')
      item3 = $('@test').find('[data-id="3"]')

      TestHelpers.mouseEventElement item1.node, 'mousedown', (item1.x()+10), (item1.y()+10)
      after 400, ->
        TestHelpers.mouseEventElement item3.find('.tags').node, 'mousemove', (item3.x()+2), (item3.y()+2)
      after 500, ->
        TestHelpers.mouseEventElement item3.node, 'mouseup'

      after 600, =>
        expect(@list.selected()[0].key).to.equal "one"
        expect(@list.selected().length).to.equal 3
        done()

    it "should deselect elements on drag ", (done) ->
      
      item1 = $('@test').find('[data-id="2"]')
      item3 = $('@test').find('[data-id="3"]')

      TestHelpers.mouseEventElement item1.node, 'mousedown', (item1.x()+10), (item1.y()+10)
      after 400, ->
        TestHelpers.mouseEventElement item3.find('.tags').node, 'mousemove', (item3.x()+2), (item3.y()+2)
      after 750, ->
        TestHelpers.mouseEventElement item1.find('.tags').node, 'mousemove', (item1.x()+2), (item1.y()+2)
      after 800, ->
        TestHelpers.mouseEventElement item1.node, 'mouseup'

      after 1000, =>
        expect(@list.selected()[0].key).to.equal "someone"
        expect(@list.selected().length).to.equal 1
        done()