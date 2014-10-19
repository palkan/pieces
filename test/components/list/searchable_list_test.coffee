'use strict'
h = require '../helpers'
utils = pi.utils
Nod = pi.Nod

describe "searchable list plugin", ->
  root = h.test_cont(pi.Nod.body)

  after ->
    root.remove()

  test_div = list = null

  beforeEach ->
    test_div = Nod.create('div')
    test_div.style position:'relative'
    root.append test_div 
    test_div.append """
        <div class="pi" data-component="list" data-plugins="searchable" data-pid="test" style="position:relative">
          <ul class="list">
            <li class="item" data-id="1" data-key="one" data-val="truth">One<span class="tags">killer,puppy</span><span class="notes">bulk</span></li>
            <li class="item" data-id="2" data-key="someone" data-val="truth">Two<span class="tags">puppy, coward</span></li>
            <li class="item" data-id="3" data-key="anyone" data-val="falsesome">Tre<span class="tags">bully,zombopuppy</span><span class="notes">zoo</span></li>
          </ul>
        </div>
      """
    pi.app.view.piecify()
    list = test_div.find('.pi')

  afterEach ->
    test_div.remove_children()

  describe "search without scope", ->

    it "should search items", ->  
      list.search 'kill'
      expect(list.size()).to.equal 1


    it "should search with discontinuation", ->  
      list.search 'tw'
      expect(list.size()).to.equal 1
      list.search 't'
      expect(list.size()).to.equal 2

      

    it "should dispatch start event", (done)->

      list.on 'searched', (event) =>
        expect(list.size()).to.equal 1
        done()  

      list.search 'kill'

    it "should dispatch update event", (done)->

      list.on 'searched', (event) =>
        expect(list.size()).to.equal 1
        done()  

      list.search 'kill'

    it "should dispatch stop event", (done)->
      list.search 'kill'
      list.on 'searched', (event) =>
        expect(list.size()).to.equal 3
        done() 
      list.search null

  describe "search within selector scope", ->

    it "should search within one-selector scope", ->    
      list.searchable.update_scope '.tags'
      list.search 'o'
      expect(list.size()).to.equal 2


    it "should search within two-selector scope", ->  
      list.searchable.update_scope '.tags,.notes'
      list.search 'bul'
      expect(list.size()).to.equal 2
      list.search 'zo'
      expect(list.size()).to.equal 1


  describe 'search result highlight', ->
    it "should highlight results", ->  
      list.search 'kill', true
      expect(list.items[0].html()).to.equal 'One<span class="tags"><mark>kill</mark>er,puppy</span><span class="notes">bulk</span>'

    it "should highlight text (not within tags)", ->  
      list.search 'on', true
      expect(list.items[0].html()).to.equal '<mark>On</mark>e<span class="tags">killer,puppy</span><span class="notes">bulk</span>'

    it "should not highlight within tags", ->  
      list.search 'p', true
      expect(list.items[0].html()).to.equal 'One<span class="tags">killer,<mark>p</mark>uppy</span><span class="notes">bulk</span>'

    it "should highlight within search scope", ->  
      list.searchable.update_scope '.tags'
      list.search 'e', true
      expect(list.items[0].html()).to.equal 'One<span class="tags">kill<mark>e</mark>r,puppy</span><span class="notes">bulk</span>'

    it "should highlight within search scope with several selectors within one item", ->  
      list.searchable.update_scope '.tags,.notes'
      list.search 'zo', true
      expect(list.items[0].html()).to.equal 'Tre<span class="tags">bully,<mark>zo</mark>mbopuppy</span><span class="notes"><mark>zo</mark>o</span>'

    it "should clear previous highlight on reduction", ->  
      list.search 'e', true
      list.search 'er', true
      expect(list.items[0].html()).to.equal 'One<span class="tags">kill<mark>er</mark>,puppy</span><span class="notes">bulk</span>'

    it "should remove all marks on search stop", ->  
      list.search 'er', true
      list.search '', true
      expect(list.items[0].html()).to.equal 'One<span class="tags">killer,puppy</span><span class="notes">bulk</span>'

    it "should remove all marks on search stop after several steps", ->  
      list.search 'e', true
      list.search 'er', true
      list.search 'e', true
      list.search '', true
      expect(list.items[0].html()).to.equal 'One<span class="tags">killer,puppy</span><span class="notes">bulk</span>'

    it "should return all not removed items on search stop", ->  
      list.search 't', true
      list.remove_item_at 0
      expect(list.size()).to.eq 1
      list.search ''
      expect(list.size()).to.eq 2

    it "should research after new item added", (done) ->
      list.search 't', true
      expect(list.size()).to.equal 2
      list.on 'update', (e) =>
        return unless e.data.type is 'item_added'
        expect(list.size()).to.equal 3
        list.search('') 
        expect(list.size()).to.equal 4
        done()
      list.add_item pi.Nod.create('''<li class="item" data-id="7" data-key="three" data-val="toast">Tetro<span class="tags">killer,zomby</span><span class="notes">lo</span></li>
            ''')