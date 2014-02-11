describe "selectable list component", ->
  beforeEach ->
    @test_div = $(document.createElement('div'))
    @test_div.css position:'relative'
    $('body').append(@test_div)
    @test_div.append """
        <div class="pi" data-component="list" data-plugins="selectable" data-pi="test" style="position:relative">
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

  describe "selectable list", ->

    it "should select one item when radio", (done)->
      
      TestHelpers.clickElement $('@test .item[data-id="1"]').get(0)

      @list.on 'item_click', (event) =>
        expect(@list.selected()[0].key).to.equal "anyone"
        done()

      TestHelpers.clickElement $('@test .item[data-id="3"]').get(0)

    it "should select several items when check", (done)->
      @list.selectable.type = 'check'

      TestHelpers.clickElement $('@test .item[data-id="1"]').get(0)

      @list.on 'item_click', (event) =>
        expect(@list.selected().length).to.equal 2
        done()

      TestHelpers.clickElement $('@test .item[data-id="3"]').get(0)


    it "should select new item", (done)->
      item = $('<li class="item" data-id="4" data-key="new">New</li>')
      @list.add_item item

      @list.on 'item_click', (event) =>
        expect(@list.selected()[0].key).to.equal 'new'
        done()

      TestHelpers.clickElement $('@test .item[data-id="4"]').get(0)
      