describe "searchable list component", ->
  Nod = pi.Nod
  root = Nod.create 'div'
  Nod.root.append root.node

  beforeEach ->
    @test_div = Nod.create 'div'
    @test_div.style position:'relative'
    root.append @test_div 
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
    @list = $('@test')

  afterEach ->
    @test_div.remove()

  describe "searchable list", ->

    it "should search items", ->  
      @list.search 'kill'
      expect(@list.size()).to.equal 1


    it "should search with discontinuation", ->  
      @list.search 'tw'
      expect(@list.size()).to.equal 1
      @list.search 't'
      expect(@list.size()).to.equal 2

      

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

  describe 'search result highlight', ->
    it "should highlight results", ->  
      @list.search 'kill', true
      expect(@list.items[0].nod.html()).to.equal 'One<span class="tags"><mark>kill</mark>er,puppy</span>'

    it "should highlight text (not within tags)", ->  
      @list.search 'on', true
      expect(@list.items[0].nod.html()).to.equal '<mark>On</mark>e<span class="tags">killer,puppy</span>'

    it "should not highlight within tags", ->  
      @list.search 'p', true
      expect(@list.items[0].nod.html()).to.equal 'One<span class="tags">killer,<mark>p</mark>uppy</span>'

    it "should clear previous highlight on reduction", ->  
      @list.search 'e', true
      @list.search 'er', true
      expect(@list.items[0].nod.html()).to.equal 'One<span class="tags">kill<mark>er</mark>,puppy</span>'

    it "should remove all marks on search stop", ->  
      @list.search 'er', true
      @list.search '', true
      expect(@list.items[0].nod.html()).to.equal 'One<span class="tags">killer,puppy</span>'

    it "should remove all marks on search stop after several steps", ->  
      @list.search 'e', true
      @list.search 'er', true
      @list.search 'e', true
      @list.search '', true
      expect(@list.items[0].nod.html()).to.equal 'One<span class="tags">killer,puppy</span>'
