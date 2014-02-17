describe "pieces utils", ->
  describe "jstime", ->
    it "should work", ->
      expect(pi.utils.jstime(12345)).to.equal(12345000)
      expect(pi.utils.jstime(123456789000)).to.equal(123456789000)

  describe "escape regexp", ->
    it "should work", ->
      expect(pi.utils.escapeRegexp("-{}()?*.$^\\")).to.equal("\\-\\{\\}\\(\\)\\?\\*\\.\\$\\^\\\\")

  describe "is email", ->
    it "should work with normal simple email", ->
      expect(pi.utils.is_email("test@example.ru")).to.be.true
    it "should fail with stupid email", ->
      expect(pi.utils.is_email("123,122@fff,ff")).to.be.false

    it "should not fail with dot-ended name email (though it is invalud due to RFC)", ->
      expect(pi.utils.is_email("some.dot.ted.@email.com")).to.be.true

    it "should work with normal email with dots and digital domain", ->
      expect(pi.utils.is_email("some.correct.dotted@112313.com")).to.be.true

  describe "camel case", ->
    it "should work with one word", ->
      expect(pi.utils.camelCase("worm")).to.equal("Worm")

    it "should work with a few words", ->
      expect(pi.utils.camelCase("little_camel_in_the_desert")).to.equal("LittleCamelInTheDesert")

  describe "snake case", ->
    it "should work with a few words", ->
      expect(pi.utils.snakeCase("CamelSong")).to.equal("camel_song")

    it "should work with non-capitalized word", ->
      expect(pi.utils.snakeCase("camelSong")).to.equal("camel_song")




  describe "serialize", ->
    it "should recognize bool", ->
      expect(pi.utils.serialize("true")).to.be.true
      expect(pi.utils.serialize("false")).to.be.false

    it "should recognize integer number", ->
      expect(pi.utils.serialize("123")).to.equal(123)

    it "should recognize float numer", ->
      expect(pi.utils.serialize("2.6")).to.equal(2.6)

    it "should recognize string", ->
      expect(pi.utils.serialize("123m535.35")).to.equal("123m535.35") 


  describe "sorting", ->
    it "should sort by key", ->
      arr = [ {key: 1}, {key: 3}, {key: 2}, {key: -2} ]
      expect(pi.utils.sort_by(arr,'key')).to.eql([ {key: 3}, {key: 2}, {key: 1}, {key: -2} ])

    it "should sort by key asc", ->
      arr = [ {key: 1}, {key: 3}, {key: 2}, {key: -2} ]
      expect(pi.utils.sort_by(arr,'key',true)).to.eql([ {key: -2}, {key: 1}, {key: 2}, {key: 3} ])

    it "should sort by many keys", ->
      arr = [ {key: 1, name: "bob"}, {key: 2, name: "jack"}, {key: 2, name: "doug"}, {key: -2} ]
      expect(pi.utils.sort(arr,['key','name'])).to.eql([ {key: 2, name:'jack'}, {key: 2, name: 'doug'}, {key: 1, name: 'bob'}, {key: -2} ])

    it "should sort by many keys asc", ->
      arr = [ {key: 1, name: "bob"}, {key: 2, name: "jack"}, {key: 2, name: "doug"}, {key: -2} ]
      expect(pi.utils.sort(arr,['name','key'],true)).to.eql([ {key: -2}, {key: 1, name: 'bob'}, {key: 2, name: 'doug'}, {key: 2, name:'jack'} ])

    it "should sort by many keys with diff orders", ->
      arr = [ {key: 1, name: "bob"}, {key: 2, name: "jack"}, {key: 2, name: "doug"}, {key: -2} ]
      expect(pi.utils.sort(arr,['key','name'],[false,true])).to.eql([ {key: 2, name:'doug'}, {key: 2, name: 'jack'}, {key: 1, name: 'bob'}, {key: -2} ])


  describe "debounce", ->
    it "should invoke on first call", ->
      spy_fun = sinon.spy()
      fun = debounce 500, spy_fun
      fun.call null
      expect(spy_fun.callCount).to.equal 1

    it "should debounce call series", (done) ->
      spy_fun = sinon.spy()
      fun = debounce 200, spy_fun
      
      after 300, =>
        expect(spy_fun.callCount).to.equal 2
        done()

      fun(0)
      fun(1)
      fun(2)
      fun(3)


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
