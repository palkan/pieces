describe "sortable list plugin", ->
  Nod = pi.Nod
  root = Nod.create 'div'
  Nod.body.append root.node

  beforeEach ->
    @test_div = Nod.create 'div'
    @test_div.style position:'relative'
    root.append @test_div 
    @test_div.append """
        <div class="pi" data-component="list" data-plugins="sortable" data-pid="test" style="position:relative">
          <ul class="list">
            <li class="item" data-val="10" data-key="one">One</li>
            <li class="item" data-val="5" data-key="one">Two</li>
            <li class="item" data-val="15" data-key="anyone">Tre</li>
          </ul>
        </div>
      """
    pi.app.view.piecify()
    @list = $('@test')

  afterEach ->
    @test_div.remove()

  describe "sortable list", ->

    it "should sort by key", ->  
      @list.sort 'val', true
      expect($('@test').first('.item').text()).to.equal 'Two'

    it "should sort by many keys", ->
      @list.sort ['key','val'], [false, false]
      expect($('@test').first('.item').text()).to.equal 'One'

    it "should dispatch sort event", (done)->
      @list.on 'sort_update', (event) =>
        expect(event.data.fields).to.eql ['key','val']
        done()
      @list.sort ['key','val']
