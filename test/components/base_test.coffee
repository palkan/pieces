'use strict'
h = require 'pi/test/helpers'

describe "Base", ->
  Nod = pi.Nod
  root = Nod.create 'div'
  Nod.body.append root.node

  root = h.test_cont(pi.Nod.body)

  before ->
    h.mock_raf()

  after ->
    h.unmock_raf()
    root.remove()

  describe "Nod extensions", ->
    it "find cut", ->
      el = Nod.create('''
        <div>
          <div id="a" class="x">
            <div id="b" class="x"></div>
          </div>
          <div>
            <div>
              <div id="c" class="x"></div>
            </div>
          </div>
          <div id="d" class="x"></div>
          <div>
            <div id="e" class="x"></div>
            <div id="f" class="x">
              <div id="g" class="x"></div>
            </div>
          </div>
        </div>
        ''')
      expect(el.find_cut('.x').map( (el) -> el.id ).join("")).to.eq "adefc"

  describe "piecify", ->
    test_div = null

    beforeEach  ->
      test_div = h.test_cont root
      test_div.append('<div class="pi test"></div>')
      pi.app.reinitialize()

    afterEach ->
      test_div.remove()

    it "init children", ->
      test = test_div.find(".test")
      test.append "<div class='pi' data-pid='some'>Some</div>"
      test.piecify()
      expect(test.some.text()).to.eq 'Some'
      expect(test.some.host).to.eq test

    it "init grandchildren", ->
      test = test_div.find(".test")
      test.append "<div class='pi' data-pid='some'>Some</div>"
      test.piecify()
      test.some.append "<div class='pi' data-pid='any'>Any</div>"
      test.piecify()
      expect(test.some.text()).to.eq 'SomeAny'
      expect(test.some.host).to.eq test
      expect(test.some.any.text()).to.eq 'Any'
      expect(test.some.any.host).to.eq test.some

    it "init list of children", ->
      test = test_div.find(".test")
      test.append '''
        <span class='pi' pid='many[]'>1</span>
        <span class='pi' pid='many[]'>2</span>
        <span class='pi' pid='many[]'>3</span>  
        '''
      test.piecify()
      expect(test.many).to.have.length 3
      expect(test.many[1].text()).to.eq '2'

  describe "events", ->
    test_div = null
    example = null

    beforeEach ->
      test_div = h.test_cont(root, '<div><div class="pi test" data-disabled="true" data-on-value="@this.text(e.data); @this.name(e.data)" data-component="test_component" data-pid="test" style="position:relative"></div></div>')
      pi.app.view.piecify()
      example = test_div.find('.test')

    afterEach ->
      test_div.remove()

    it "send enabled event", (done) ->
      example.on 'enabled', (event) => 
        expect(example.enabled).to.be.true
        done()
      example.enable()

    it "don't send enabled event", (done) ->
      example.on 'enabled', (event) => 
        expect(example.enabled).to.be.true
        done()
      example.disable()
      pi.utils.after 500, => 
        expect(example.enabled).to.be.false
        done()

    it "send resize event", (done) ->
      example.enable()
      example.on 'resize', (event) => 
        expect(example.size()).to.include width:100, height: 50
        done()
      example.size(100,50)

    it "pass event data as arg to multiple handlers", ->
      example.enable()
      example.value_trigger "abc"
      expect(example.text()).to.equal("abc")
      expect(example.name()).to.equal("abc")

  describe "events bubbling", ->
    test_div = null
    example = null
    
    beforeEach  ->
      test_div = h.test_cont root, '<div><div class="pi test" data-pid="test">
                          <a class="pi" data-disabled="true" data-pid="btn" href="#">clicko</a>
                        </div></div>'
      pi.app.view.piecify()
      example = test_div.find('.test')

    afterEach ->
      test_div.remove()

    it "bubble event", (done) ->
      example.listen 'a', 'enabled', (event) => 
        expect(event.target).to.eq(example.btn)
        expect(event.currentTarget).to.eq(example)
        expect(example.btn.enabled).to.be.true
        done()
      example.btn.enable()

  describe "callbacks", ->
    test_div = example = null
    beforeEach  ->
      test_div = h.test_cont root, '<div><div class="pi test" data-pid="test" data-id="2">
                        </div></div>'
      pi.app.view.piecify()
      example = test_div.find('.test')

    it "run before_create callback", (done) ->
      example.on 'value', (event) => 
        expect(event.data).to.eq 13
        done()
      h.clickElement example.node

    it "run after_initialize callback", ->
      expect(example.id).to.eq 2

  