describe "pieces core", ->
  beforeEach ->
    @test_div = $(document.createElement('div'))
    @test_div.css position:'relative'
    $('body').append(@test_div)

  afterEach ->
    @test_div.remove()

  describe "global functions", ->
    it "should correctly parse options", ->
      el = $('<div data-component="test" data-option-hidden="true" data-option-collection-id="13" data-plugins="autoload search filter"></div>')
      options = pi.gather_options el
      expect(options).to.include({component:"test",hidden:true,collection_id:13}).and.to.have.property('plugins').with.length(3)
    it "should correctly init base component", ->
      el = $('<div data-component="test_component" data-option-hidden="true"></div>')
      component = pi.init_component el
      expect(component).to.be.an.instanceof pi.TestComponent
      expect(component.visible).to.be.false
    it "should throw error on undefined component", ->
      el = $('<div data-component="testtt" data-option-hidden="true"></div>')
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
      expect($('@test').pi()).to.be.an.instanceof pi.TestComponent

    it "should work with simple function call", ->
      TestHelpers.clickElement $('a#hide').get(0)
      expect($('@test').pi().visible).to.be.false

    it "should work with several function calls", ->
      TestHelpers.clickElement $('a#hide').get(0)
      expect($('@test').pi().visible).to.be.false
      TestHelpers.clickElement $('a#show').get(0)
      expect($('@test').pi().visible).to.be.true

    it "should work with function call with one argument", ->
      TestHelpers.clickElement $('a#text').get(0)
      expect($('@test').pi().text()).to.equal('hello_test')

    it "should work with function call with several arguments", ->
      TestHelpers.clickElement $('a#move').get(0)
      expect($('@test').pi().position()).to.include({x:20,y:30})

    it "should work with self call", ->
      TestHelpers.clickElement $('a#thiz').get(0)
      expect($('a#thiz').pi().active).to.be.true

    it "should work with only component (without method)", ->
      TestHelpers.clickElement $('a#append').get(0)
      expect($('@test .pi').text()).to.equal 'Append me'

    it "should work with only component (without method) on event", ->
      TestHelpers.clickElement $('span#append_click').get(0)
      expect($('@test .pi').text()).to.equal 'Append me'

    it "should work with only component self (without method)", ->
      TestHelpers.clickElement $('a#append_self').get(0)
      expect($('@test .pi').text()).to.equal 'Append self'



  describe "pi complex call queries", ->
    beforeEach  ->
      @test_div.append('<div class="pi" data-component="test_component" data-event-click="@this.text(@this.value)" data-value="13" data-pi="test1" style="position:relative">ping</div>')
      @test_div.append('<div class="pi" data-component="test_component" data-pi="test2" style="position:relative"></div>')

      @test_div.append('<a id="call1" href="@test1.text(pong)">Text</div>')
      @test_div.append('<a id="call2" href="@test2.text(@test1.text)">Text</div>')
      @test_div.append('<a id="call3" href="@test2.btn.hide">Hide</div>')
      @test_div.find('@test2').append('<a class="btn" data-component="base" href="@test1.hide">Hide</div>')
      pi.piecify()

    it "should work with nested component", ->
      TestHelpers.clickElement $('a#call3').get(0)
      expect($('@test2').pi().btn.visible).to.be.false
     
    it "should work with bound call", ->
      TestHelpers.clickElement $('a#call2').get(0)
      expect($('@test2').pi().text()).to.equal('ping')
      
      TestHelpers.clickElement $('a#call1').get(0)
      TestHelpers.clickElement $('a#call2').get(0)
      expect($('@test2').pi().text()).to.equal('pong')

    it "should work with self bound call", ->
      TestHelpers.clickElement $('@test1').get(0)
      expect($('@test1').pi().text()).to.equal '13'
    

  describe "pi base events", ->
    beforeEach  ->
      @test_div.append('<div class="pi" data-option-disabled="true" data-component="test_component" data-pi="test" style="position:relative"></div>')
      pi.piecify()
      @example = $('@test').pi()

    it "should send enabled event", (done) ->
      @example.on 'enabled', (event) => 
        expect(@example.enabled).to.be.true
        done()
      @example.enable()

    it "should send enabled event with flag", (done) ->
      @example.on 'enabled_true', (event) => 
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

    it "should send resize event on width change", (done) ->
      @example.enable()
      @example.on 'resize', (event) => 
        expect(@example.width()).to.equal(100)
        done()
      @example.width(100)

    it "should send resize event on height change", (done) ->
      @example.enable()
      @example.on 'resize', (event) => 
        expect(@example.height()).to.equal(50)
        done()
      @example.height(50)
