describe "sortable list component", ->
  beforeEach ->
    @test_div = $(document.createElement('div'))
    @test_div.css position:'relative'
    $('body').append(@test_div)
    @test_div.append """
        <div class="pi" data-component="list" data-plugins="sortable" data-pi="test" style="position:relative">
          <ul class="list">
            <li class="item" data-val="10" data-key="one">One</li>
            <li class="item" data-val="5" data-key="one">Two</li>
            <li class="item" data-val="15" data-key="anyone">Tre</li>
          </ul>
        </div>
      """
    pi.piecify()
    @list = $('@test').pi()

  afterEach ->
    @test_div.remove()

  describe "sortable list", ->

    it "should sort by key", ->  
      @list.sort 'val', true
      expect($('@test .item').first().text()).to.equal 'Two'

    it "should sort by many keys", ->
      @list.sort ['key','val'], [false, false]
      expect($('@test .item').first().text()).to.equal 'One'

    it "should dispatch sort event", (done)->
      @list.on 'sort_update', (event) =>
        expect(event.data.fields).to.eql ['key','val']
        done()
      @list.sort ['key','val']
