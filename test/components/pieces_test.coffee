'use strict'
TestHelpers = require './helpers'

describe "pieces core", ->
  Nod = pi.Nod
  root = Nod.create 'div'
  Nod.body.append root.node

  beforeEach ->
    @test_div = Nod.create 'div'
    @test_div.style position:'relative'
    root.append @test_div 

  afterEach ->
    root.html ''

  describe "Nod extensions", ->
    it "should find cut", ->
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

  describe "global functions", ->
    it "should correctly parse options", ->
      el = Nod.create('<div data-component="test" data-hidden="true" data-collection-id="13" data-plugins="autoload search filter"></div>')
      options = pi._gather_options el
      expect(options).to.include({component:"test",hidden:true,collection_id:13}).and.to.have.property('plugins').with.length(3)
    it "should correctly init base component", ->
      el = Nod.create('<div data-component="test_component" data-hidden="true"></div>')
      component = pi.init_component el
      expect(component).to.be.an.instanceof pi.TestComponent
      expect(component.visible).to.be.false
    it "should return undefined if component not found", ->
      el = Nod.create('<div data-component="testtt" data-hidden="true"></div>')
      expect(pi.init_component(el)).to.be.undefined

  describe "find cut", ->
    it "should find cut", ->
      _html = '''
      <h1 class="title">File input</h1>
      <div class="content">
        <div class="inline">
          <div pid="btn" data-on-files_selected="@host.list.data_provider(e.data)" class="pi button-blue file-input-wrap">choose file
            <input type="file" class="file-input">
          </div>
          <div data-on-selected="@host.btn.multiple(e.data)" class="pi checkbox-wrap">
            <label class="cb-label">Multiple?</label>
            <input type="hidden">
          </div>
        </div>
        <div pid="list" data-renderer="mustache(file_item_mst)" class="pi inline list-container">
          <ul class="list"></ul>
        </div>
      </div>
      '''
      el = Nod.create('div')
      el = pi.init_component el
      el.html _html
      expect(el.find_cut('.pi')).to.have.length 3

  describe "pi piecify and click hanlder", ->
    beforeEach  ->
      @test_div.append('<div class="pi" data-component="test_component" data-pid="test" style="position:relative"></div>')
      @test_div.append('<a id="hide" href="@test.hide">Hide</div>')
      @test_div.append('<a id="show" href="@test.show">Show</div>')
      @test_div.append('<a id="text" href="@test.text(hello_test)">Text</div>')
      @test_div.append('<a id="move" href="@test.move(20,30)">Move</div>')
      @test_div.append('<a id="append" href="@test.append(@span)">Append</div>')
      @test_div.append('<span id="append_click" class="pi" data-on-click="@test.append(@span)">Append</div>')
      @test_div.append('<a id="append_self" class="pi" href="@test.append(@this)">Append self</div>')
      @test_div.append('<span class="pi" data-pid="span">Append me</span>')
      @test_div.append('<a id="thiz" class="pi" data-component="test_component" href="@this.activate">Active This</div>')
      pi.app.view.piecify()

    it "should create piece", ->
      expect(pi.app.view.test).to.be.an.instanceof pi.TestComponent

    it "should work with simple function call", ->
      TestHelpers.clickElement $('a#hide').node
      expect($('@test').visible).to.be.false

    it "should work with several function calls", ->
      TestHelpers.clickElement $('a#hide').node
      expect($('@test').visible).to.be.false
      TestHelpers.clickElement $('a#show').node
      expect($('@test').visible).to.be.true

    it "should work with function call with one argument", ->
      TestHelpers.clickElement $('a#text').node
      expect($('@test').text()).to.equal('hello_test')

    it "should work with function call with several arguments", ->
      TestHelpers.clickElement $('a#move').node
      expect($('@test').offset()).to.include({x:20,y:30})

    it "should work with self call", ->
      TestHelpers.clickElement $('a#thiz').node
      expect($('a#thiz').active).to.be.true

    it "should work with only component (without method)", ->
      TestHelpers.clickElement $('a#append').node
      expect($('@test').find("span").text()).to.equal 'Append me'

    it "should work with only component on event", ->
      TestHelpers.clickElement $('span#append_click').node
      expect($('@test').find("span").text()).to.equal 'Append me'

    it "should work with only component self (without method)", ->
      TestHelpers.clickElement $('a#append_self').node
      expect($('@test').find('#append_self').text()).to.equal 'Append self'

    describe "piecify", ->
      it "should init children", ->
        test = $("@test")
        test.append "<div class='pi' data-pid='some'>Some</div>"
        test.piecify()
        expect(test.some.text()).to.eq 'Some'
        expect(test.some.host).to.eq test

      it "should init grandchildren", ->
        test = $("@test")
        test.append "<div class='pi' data-pid='some'>Some</div>"
        test.piecify()
        test.some.append "<div class='pi' data-pid='any'>Any</div>"
        test.piecify()
        expect(test.some.text()).to.eq 'SomeAny'
        expect(test.some.host).to.eq test
        expect(test.some.any.text()).to.eq 'Any'
        expect(test.some.any.host).to.eq test.some

      it "should init list of children", ->
        test = $("@test")
        test.append '''
          <span class='pi' pid='many[]'>1</span>
          <span class='pi' pid='many[]'>2</span>
          <span class='pi' pid='many[]'>3</span>  
          '''
        test.piecify()
        expect(test.many).to.have.length 3
        expect(test.many[1].text()).to.eq '2'

  describe "pi base events", ->
    beforeEach  ->
      @test_div.append('<div class="pi" data-disabled="true" data-on-value="@this.text(e.data); @this.name(e.data)" data-component="test_component" data-pid="test" style="position:relative"></div>')
      pi.app.view.piecify()
      @example = $('@test')

    it "should send enabled event", (done) ->
      @example.on 'enabled', (event) => 
        expect(@example.enabled).to.be.true
        done()
      @example.enable()

    it "should send enabled event", (done) ->
      @example.on 'enabled', (event) => 
        expect(@example.enabled).to.be.true
        done()
      @example.enable()

    it "should not send enabled event", (done) ->
      @example.on 'enabled', (event) => 
        expect(@example.enabled).to.be.true
        done()
      @example.disable()
      after 500, => 
        expect(@example.enabled).to.be.false
        done()

    it "should send resize event", (done) ->
      @example.enable()
      @example.on 'resize', (event) => 
        expect(@example.size()).to.include width:100, height: 50
        done()
      @example.size(100,50)

    it "should pass event data as arg to multiple handlers", ->
      @example.enable()
      @example.value_trigger "abc"
      expect(@example.text()).to.equal("abc")
      expect(@example.name()).to.equal("abc")

  describe "events bubbling", ->
    beforeEach  ->
      @test_div.append '<div class="pi test" data-pid="test">
                          <a class="pi" data-disabled="true" data-pid="btn" href="#">clicko</a>
                        </div>'
      pi.app.view.piecify()
      @example = $('@test')

    it "should bubble event", (done) ->
      @example.listen 'a', 'enabled', (event) => 
        expect(event.target).to.eq(@example.btn)
        expect(event.currentTarget).to.eq(@example)
        expect(@example.btn.enabled).to.be.true
        done()
      @example.btn.enable()

  describe "callbacks", ->
    beforeEach  ->
      @test_div.append '<div class="pi test" data-pid="test" data-id="2">
                        </div>'
      pi.app.view.piecify()
      @example = $('@test')

    it "should run before_create callback", (done) ->
      @example.on 'value', (event) => 
        expect(event.data).to.eq 13
        done()
      TestHelpers.clickElement @example.node

    it "should run after_initialize callback", ->
      expect(@example.id).to.eq 2

  describe "renderable", ->
    beforeEach  ->
      window.JST ||= {}
      window.JST['test/base'] = (data) ->
        nod = Nod.create("<div>#{ data.name }</div>")
        nod.append "<span class='author'>#{ data.author }</span>"
        nod.append "<button class='pi' pid='some_btn'>Button</button>"
        nod  

      @test_div.append '''<div class="pi test" data-plugins="renderable" data-renderer="jst(test/base)" data-pid="test" data-id="2">
                          <div>John
                            <span class="author">Green</span>
                            <button class="pi" pid="some_btn">Button</button>
                          </div>
                        </div>'''
      pi.app.view.piecify()
      @example = $('@test')

    it "should have render function", ->
      expect(@example.render).to.be.an 'function'

    it "should remove old dispose old components and init new", ->
      old_btn = @example.some_btn
      @example.render name: 'Jack', author: 'Sparrow'

      expect(old_btn._disposed).to.be.true
      expect(@example.text()).to.eq 'JackSparrowButton'
      expect(@example.some_btn).to.be.an.instanceof pi.Button
      expect(@example.__components__).to.have.length 1
      expect(@example.some_btn).not.to.eq old_btn

    it "should remove children if render null", ->
      old_btn = @example.some_btn
      @example.render null
      expect(old_btn._disposed).to.be.true
      expect(@example.text()).to.eq ''
      expect(@example.__components__).to.have.length 0
      expect(@example.some_btn).to.be.undefined
