'use strict'
TestHelpers = require '../helpers'

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
      @list.sort {val: 'asc'}
      expect($('@test').first('.item').text()).to.equal 'Two'

    it "should sort by many keys", ->
      @list.sort [{key:'desc'},{val:'desc'}], [false, false]
      expect($('@test').first('.item').text()).to.equal 'One'

    it "should dispatch sort event", (done)->
      @list.on 'sort_update', (event) =>
        expect(event.data[0]).to.eql {key:'asc'}
        expect(event.data[1]).to.eql {val:'asc'}
        done()
      @list.sort [{key:'asc'},{val:'asc'}]

    it "should resort items if item updated", (done)->
      @list.sort {val: 'asc'}
      @list.on 'update', (event) =>
        return unless event.data.type is 'item_updated'
        expect($('@test').first('.item').text()).to.eq 'Tre'
        done()
      @list.where(record: key: 'anyone')[0].record.val = 2
      @list.trigger 'update', type: 'item_updated'

    it "should resort items if item added", (done)->
      @list.sort {val: 'asc'}
      @list.on 'update', (event) =>
        return unless event.data.type is 'item_added'
        expect($('@test').first('.item').text()).to.eq 'Zero'
        done()

      @list.add_item pi.Nod.create('''<li class="item" data-val="2" data-key="some">Zero</li>''')