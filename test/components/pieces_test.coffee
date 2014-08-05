describe "pieces core", ->
  Nod = pi.Nod
  root = Nod.create 'div'
  Nod.root.append root.node

  beforeEach ->
    @test_div = Nod.create 'div'
    @test_div.style position:'relative'
    root.append @test_div 

  afterEach ->
    root.html ''

  describe "global functions", ->
    it "should correctly parse options", ->
      el = Nod.create_html('<div data-component="test" data-option-hidden="true" data-option-collection-id="13" data-plugins="autoload search filter"></div>')
      options = pi.gather_options el
      expect(options).to.include({component:"test",hidden:true,collection_id:13}).and.to.have.property('plugins').with.length(3)
    it "should correctly init base component", ->
      el = Nod.create_html('<div data-component="test_component" data-option-hidden="true"></div>')
      component = pi.init_component el
      expect(component).to.be.an.instanceof pi.TestComponent
      expect(component.visible).to.be.false
    it "should throw error on undefined component", ->
      el = Nod.create_html('<div data-component="testtt" data-option-hidden="true"></div>')
      expect(curry(pi.init_component,el)).to.throw(ReferenceError)

  describe "pi piecify and click hanlder", ->
    beforeEach  ->
      @test_div.append('<div class="pi" data-component="test_component" data-pi="test" style="position:relative"></div>')
      @test_div.append('<a id="hide" href="@test.hide">Hide</div>')
      @test_div.append('<a id="show" href="@test.show">Show</div>')
      @test_div.append('<a id="text" href="@test.text(hello_test)">Text</div>')
      @test_div.append('<a id="move" href="@test.move(20,30)">Move</div>')
      @test_div.append('<a id="append" href="@test.append(@span)">Append</div>')
      @test_div.append('<span id="append_click" class="pi" data-event-click="@test.append(@span)">Append</div>')
      @test_div.append('<a id="append_self" class="pi" href="@test.append(@this)">Append self</div>')
      @test_div.append('<span class="pi" data-pi="span">Append me</span>')
      @test_div.append('<a id="thiz" class="pi" data-component="test_component" href="@this.activate">Active This</div>')
      pi.piecify()

    it "should create piece", ->
      expect(pi.find('test')).to.be.an.instanceof pi.TestComponent

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
      expect($('@test').find('.pi').text()).to.equal 'Append me'

    it "should work with only component (without method) on event", ->
      TestHelpers.clickElement $('span#append_click').node
      expect($('@test').find('.pi').text()).to.equal 'Append me'

    it "should work with only component self (without method)", ->
      TestHelpers.clickElement $('a#append_self').node
      expect($('@test').find('.pi').text()).to.equal 'Append self'



  describe "pi complex call queries", ->
    beforeEach  ->
      @test_div.append('<div class="pi" data-component="test_component" data-event-click="@this.text(@this.data(\'value\'))" data-value="13" data-pi="test1" style="position:relative">ping</div>')
      @test_div.append('<div class="pi test2" data-component="test_component" data-option-name="test2" data-pi="test2" style="position:relative"></div>')

      @test_div.append('<a id="call1" href="@test1.text(pong)">Text</div>')
      @test_div.append('<a id="call2" href="@test2.text(@test1.text)">Text</div>')
      @test_div.append('<a id="call3" href="@test2.btn.hide">Hide</div>')
      @test_div.append('<a id="call4" href="@test1.text(ABC)">ABC</div>')
      @test_div.append('<a id="call5" href="@test1.addClass(\'A\',\'B\',\'is-dead\')">ABC</div>')
      @test_div.append('<a id="call6" href="@test1.addClass(@test2.name(),\'B\')">ABC</div>')
      @test_div.find('.test2').append('<a class="btn" data-component="base" href="@test1.hide">Hide</div>')
      pi.piecify()

    it "should work with nested component", ->
      TestHelpers.clickElement $('a#call3').node
      expect($('@test2').btn.visible).to.be.false

    it "should work with bound call", ->
      TestHelpers.clickElement $('a#call2').node
      expect($('@test2').text()).to.equal('ping')
      
      TestHelpers.clickElement $('a#call1').node
      TestHelpers.clickElement $('a#call2').node
      expect($('@test2').text()).to.equal('pong')

    it "should work with self bound call", ->
      TestHelpers.clickElement $('@test1').node
      expect($('@test1').text()).to.equal '13'

    it "should work with several args in call", ->
      TestHelpers.clickElement $('a#call5').node
      expect($('@test1').hasClass('A')).to.be.true
      expect($('@test1').hasClass('B')).to.be.true
      expect($('@test1').hasClass('is-dead')).to.be.true

    it "should work with several args and nested call", ->
      TestHelpers.clickElement $('a#call6').node
      expect($('@test1').hasClass('test2')).to.be.true
      expect($('@test1').hasClass('B')).to.be.true
    

  describe "pi base events", ->
    beforeEach  ->
      @test_div.append('<div class="pi" data-option-disabled="true" data-event-value="@this.text; @this.name" data-component="test_component" data-pi="test" style="position:relative"></div>')
      pi.piecify()
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
      @test_div.append '<div class="pi" data-option-disabled="true" data-component="test_component" data-pid="test">
                          <a class="pi" data-pid="btn" href="#">clicko</a>
                        </div>'
      pi.piecify()
      @example = $('@test')

    it "should bubble event", (done) ->
      @example.listen '.a', 'enabled', (event) => 
        expect(event.target).to.eq(@example.btn)
        expect(event.currentTarget).to.eq(@example)
        expect(@example.btn).to.be.true
        done()
      @example.btn.enable()
