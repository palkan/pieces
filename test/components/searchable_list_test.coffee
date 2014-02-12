describe "searchable list component", ->
  beforeEach ->
    @test_div = $(document.createElement('div'))
    @test_div.css position:'relative'
    $('body').append(@test_div)
    @test_div.append """
        <div class="pi" data-component="list" data-plugins="searchable" data-pi="test" style="position:relative">
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

  describe "searchable list", ->

    it "should search items", ->  
      @list.search 'kill'
      expect(@list.size()).to.equal 1

    it "should dispatch start event", (done)->

      @list.on 'search_start', (event) =>
        expect(@list.size()).to.equal 3
        done()  

      @list.search 'kill'

    it "should dispatch update event", (done)->

      @list.on 'search_update', (event) =>
        expect(@list.size()).to.equal 1
        done()  

      @list.search 'kill'

    it "should dispatch stop event", (done)->

      @list.on 'search_stop', (event) =>
        expect(@list.size()).to.equal 3
        done()  

      @list.search 'kill'
      @list.search null
