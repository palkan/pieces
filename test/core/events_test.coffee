describe "event dispatcher", ->
    beforeEach  ->
      @test_div = $(document.createElement('div'))
      @test_div.css position:'relative'
      $('body').append(@test_div)
      @test_div.append('<div class="pi" data-component="test_component" data-pi="test" style="position:relative"></div>')
      pi.piecify()

    afterEach ->
      @test_div.remove()


    it "should parse dom and add event handlers", ->
      @test_div.append """
        <div id='cont'>
          <button class='pi' data-component='base' data-pi='btn' data-event-click='@test.hide' data-event-custom='@test.show'>Button</button>
        </div>
          """
      $("#cont").piecify()
      expect($("@btn").pi().listeners).to.have.keys(['click','custom'])

    it "should add native events and call handlers", (done)->
      @test_div.append """
        <div id='cont'>
          <button class='pi' data-component='base' data-pi='btn'>Button</button>
        </div>
          """
      $("#cont").piecify()
      el = $("@btn").pi()
      count = 0
      el.on 'click', (event) =>
        count++
  
      el.on 'click', (event) =>
        count++
      
      after 500, =>
        done() if count == 2

      TestHelpers.clickElement $("@btn").get(0)

    it "should add custom events and call handlers", (done)->
      @test_div.append """
        <div id='cont'>
          <button class='pi' data-component='base' data-pi='btn'>Button</button>
        </div>
          """
      $("#cont").piecify()
      el = $("@btn").pi()
      
      count = 
        total: 0
        value: 0


      el.on 'enabled', (event) =>
        count.total++
        if el.enabled then count.value++ else count.value--

      el.on 'enabled', (event) =>
        count.total++
        if el.enabled then count.value++ else count.value--

      after 500, =>
        if count.total == 4 and count.value == 0
          done()

      el.disable()
      el.enable()

    it "should remove all events on off", ->
      @test_div.append """
        <div id='cont'>
          <button class='pi' data-component='base' data-event-click='@test.hide' data-event-custom='@test.show' data-pi='btn'>Button</button>
        </div>
          """
      $("#cont").piecify()
      el = $("@btn").pi()
      el.off()
      expect(el.listeners).to.eql({})

    it "should not call removed events", (done)->
      @test_div.append """
        <div id='cont'>
          <button class='pi' data-component='base' data-event-click='@test.hide' data-event-custom='@test.show' data-pi='btn'>Button</button>
        </div>
          """
      $("#cont").piecify()
      el = $("@btn").pi()
      
      count = 0

      el.on 'enabled', (event) =>
        count.total++
      
      el.on 'click', (event) =>
        count.total++
      
      after 500, =>
        if count == 0
          done()

      el.off()
        
      TestHelpers.clickElement $("@btn").get(0)
      el.disable()
      el.enable()

    it "should remove native listener on off()", ->
      @test_div.append """
        <div id='cont'>
          <button class='pi' data-component='base' data-pi='btn'>Button</button>
        </div>
          """
      $("#cont").piecify()
      el = $("@btn").pi()

      spy = sinon.spy(el,"native_event_listener")

      el.on "click", (event) => "hello"

      dummy =
        kill: -> true

      el.on "click", dummy.kill, dummy
      
      TestHelpers.clickElement $("@btn").get(0)
      
      el.off()
      
      TestHelpers.clickElement $("@btn").get(0)
      TestHelpers.clickElement $("@btn").get(0)
      
      expect(el.listeners).to.eql {}
      expect(spy.callCount).to.equal(1)

    it "should remove native listener on off(event)", ->
      @test_div.append """
        <div id='cont'>
          <button class='pi' data-component='base' data-pi='btn'>Button</button>
        </div>
          """
      $("#cont").piecify()
      el = $("@btn").pi()

      spy = sinon.spy(el,"native_event_listener")

      el.on "click", (event) => "hello"

      dummy =
        kill: -> true

      el.on "click", dummy.kill, dummy     

      TestHelpers.clickElement $("@btn").get(0)
      
      el.off 'click'
      
      TestHelpers.clickElement $("@btn").get(0)
      TestHelpers.clickElement $("@btn").get(0)
      
      expect(el.listeners.click).to.be.undefined
      expect(spy.callCount).to.equal(1)


    it "should remove native listener on off(event,callback,context)", ->
      @test_div.append """
        <div id='cont'>
          <button class='pi' data-component='base' data-pi='btn'>Button</button>
        </div>
          """
      $("#cont").piecify()
      el = $("@btn").pi()
      spy = sinon.spy(el,"native_event_listener")
      
      dummy =
        kill: -> pi.utils.debug('kill')

      el.on "click", dummy.kill, dummy

      TestHelpers.clickElement $("@btn").get(0)
      
      el.off 'click', dummy.kill, dummy 
      
      TestHelpers.clickElement $("@btn").get(0)
      TestHelpers.clickElement $("@btn").get(0)

      expect(el.listeners.click).to.be.undefined
      expect(spy.callCount).to.equal(1)

    it "should call once if one(event)", ->
      @test_div.append """
        <div id='cont'>
          <button class='pi' data-component='base' data-pi='btn'>Button</button>
        </div>
          """
      $("#cont").piecify()
      el = $("@btn").pi()
      
      
      dummy =
        kill: -> pi.utils.debug('kill')

      spy = sinon.spy(dummy,"kill")

      el.one "click", dummy.kill, dummy

      TestHelpers.clickElement $("@btn").get(0)
      TestHelpers.clickElement $("@btn").get(0)
      TestHelpers.clickElement $("@btn").get(0)

#      expect(el.listeners.click).to.be.undefined
      expect(spy.callCount).to.equal(1)

    it "should remove native listener after event if one(event)", ->
      @test_div.append """
        <div id='cont'>
          <button class='pi' data-component='base' data-pi='btn'>Button</button>
        </div>
          """
      $("#cont").piecify()
      el = $("@btn").pi()
      
      spy = sinon.spy(el,"native_event_listener")
      
      dummy =
        kill: -> pi.utils.debug('kill')

      el.one "click", dummy.kill, dummy

      TestHelpers.clickElement $("@btn").get(0)
      TestHelpers.clickElement $("@btn").get(0)
      TestHelpers.clickElement $("@btn").get(0)

      expect(el.listeners.click).to.be.undefined
      expect(spy.callCount).to.equal(1)

    it "should work with several native events", ->
      @test_div.append """
        <div id='cont'>
          <button class='pi' data-component='base' data-pi='btn'>Button</button>
        </div>
          """
      $("#cont").piecify()
      el = $("@btn").pi()
      
      spy = sinon.spy(el,"native_event_listener")
      spy_fun = sinon.spy()
      
      el.on "click", spy_fun
      el.on "mouseover", spy_fun

      TestHelpers.clickElement $("@btn").get(0)
      
      el.off "click"

      TestHelpers.mouseEventElement $("@btn").get(0), "mouseover"
      TestHelpers.clickElement $("@btn").get(0)

      expect(el.listeners.click).to.be.undefined
      expect(el.listeners.mouseover).to.have.length(1)
      expect(spy.callCount).to.equal(2)
      expect(spy_fun.callCount).to.equal(2)
