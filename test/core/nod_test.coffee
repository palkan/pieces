describe "pieces nod", ->

  Nod = pi.Nod

  describe "class functions", ->
    it "should create element", ->
      nod = Nod.create 'div'
      expect(nod.node.nodeName.toLowerCase()).to.equal 'div'
      expect(nod.node._nod).to.equal nod

    it "should create element only once", ->
      nod = Nod.create 'div'
      nod2 = Nod.create nod
      nod3 = Nod.create nod.node
      expect(nod).to.equal nod2
      expect(nod2).to.equal nod3
      expect(nod3).to.equal nod

    it "should return null argument passed but null", ->
      nod = Nod.create null
      expect(nod).to.be.null

    it "should create element with tag", ->
      nod = Nod.create 'a'
      expect(nod.node.nodeName.toLowerCase()).to.equal 'a'

    it "should create element with html content", ->
      nod = Nod.create '<a href="@test">Test</a>'
      expect(nod.node.nodeName.toLowerCase()).to.equal 'a'
      expect(nod.attr('href')).to.equal '@test'
      expect(nod.text()).to.equal 'Test'


  describe "instance functions", ->

    test_root = Nod.create 'div'
    Nod.root.append test_root.node

    beforeEach ->
      @test_div = Nod.create 'div'
      test_root.node.appendChild(@test_div.node)

    afterEach ->
      test_root.html('')
  
    it "should find element", ->
      @test_div.html('<a href="#">1</a><span class="a">2</span><span id="b">3</span>')
      expect(@test_div.find('a').text()).to.equal "1"
      expect(@test_div.find('.a').text()).to.equal "2"
      expect(@test_div.find('#b').text()).to.equal "3"

    it "should find only one element", ->
      @test_div.html('<a href="#">1</a><a href="#">2</a>')
      expect(@test_div.find('a').text()).to.equal "1"

    it "should return children (equal size)", ->
      @test_div.html('<a href="#">1</a><a href="#">2</a>')
      expect(@test_div.children().length).to.equal 2

    it "should work with each", ->
      @test_div.html('<a class="a" href="#">1</a><div><span class="a">2</span></div><span class="a">3</span>')
      r = ""
      @test_div.each('.a', (node) -> r+= node.textContent)
      expect(r).to.equal "123"

    it "should append child", ->
      @test_div.html('<span>0</span>')
      a = Nod.create 'a'
      a.text '1'
      @test_div.append a
      expect(@test_div.html()).to.equal '<span>0</span><a>1</a>'

    it "should prepend child", ->
      @test_div.html('<span>0</span>')
      a = Nod.create 'a'
      a.text '1'
      @test_div.prepend a
      expect(@test_div.html()).to.equal '<a>1</a><span>0</span>'

    it "should append html string", ->
      @test_div.html('<span>0</span>')
      @test_div.append '<a>1</a>'
      expect(@test_div.html()).to.equal '<span>0</span><a>1</a>'

    it "should insert element after", ->
      @test_div.html('<span>0</span>')
      a = Nod.create 'a'
      a.text '1'
      @test_div.insertAfter a
      expect(test_root.html()).to.equal '<div><span>0</span></div><a>1</a>'

    it "should insert element before", ->
      @test_div.html('<span>0</span>')
      a = Nod.create 'a'
      a.text '1'
      @test_div.insertBefore a
      expect(test_root.html()).to.equal '<a>1</a><div><span>0</span></div>'

    it "should insert element before as string", ->
      @test_div.html('<span>0</span>')
      @test_div.insertBefore '<a>1</a>'
      expect(test_root.html()).to.equal '<a>1</a><div><span>0</span></div>'


    it "should wrap itself", ->
      @test_div.wrap()
      expect(test_root.html()).to.equal '<div><div></div></div>'

    it "should find parent", ->
      @test_div.html('<span>0</span>')
      sp = @test_div.find('span')
      expect(sp.parent()).to.eq @test_div

    it "should find parent by selector", ->
      @test_div.html('<div class="a"><div class="b"><span>1</span></div></div>')
      @test_div.addClass 'pi'
      sp = @test_div.find('span')
      dv = @test_div.find('.a')
      dv2 = @test_div.find('.b')
      expect(sp.parent('.a')).to.eq dv
      expect(sp.parent('.b')).to.eq dv2
      expect(sp.parent('.pi')).to.eq @test_div



    it "should clone", ->
      @test_div.html '<span>Hi!</span>'
      a = @test_div.clone()
      @test_div.insertAfter a
      @test_div.html '<span>Hello!</span>'
      expect(test_root.html()).to.equal '<div><span>Hello!</span></div><div><span>Hi!</span></div>'

    describe 'hash functions', ->

      beforeEach ->
        @test_div = Nod.create """
          <div data-a="1" data-b="2" data-long-name="3" style="color:black;position:relative" class="test example">
            <input type="text" value="1"/>
          </div>
          """
        test_root.node.appendChild(@test_div.node)

      afterEach ->
        test_root.html('')

      it "should read serialized data attributes", ->
        expect(@test_div.data('a')).to.equal 1
        expect(@test_div.data('long_name')).to.equal 3
        expect(@test_div.data()).to.eql {a: 1, b: 2, long_name: 3}

      it "should write data attributes", ->
        @test_div.data('a', '11')
        expect(@test_div.data('a')).to.equal '11'
        @test_div.data('c', '22')
        expect(@test_div.data('c')).to.equal '22'

