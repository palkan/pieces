describe "action_list component", ->
  Nod = pi.Nod
  root = Nod.create 'div'
  Nod.body.append root.node

  beforeEach ->
    @test_div = Nod.create 'div'
    @test_div.style position:'relative'
    root.append @test_div 
    @test_div.append """
        <div class="pi action-list" data-pid="test" style="position:relative">
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

  describe "action list plugins", ->

    it "should select one item", (done)->
      
      TestHelpers.clickElement $('@test').find('[data-id="1"]').node

      @list.on 'item_click', (event) =>
        expect(@list.selected()[0].key).to.equal "anyone"
        done()

      TestHelpers.clickElement $('@test').find('[data-id="3"]').node

    it "should filter with one-key object", ->
      @list.filter key: 'someone'
      expect(@list.size()).to.equal 1
      @list.filter id: 2
      expect(@list.size()).to.equal 1

    it "should search items", ->  
      @list.search 'kill'
      expect(@list.size()).to.equal 1

    it "should sort by key", ->  
      @list.sort 'key', true
      expect($('@test').first('.item .tags').text()).to.equal 'bully,zombopuppy'