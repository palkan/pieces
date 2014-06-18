describe "pieces nod", ->

  Nod = pi.Nod

  describe "class functions", ->
    it "should create element", ->
      nod = Nod.create()
      expect(nod.node.nodeName.toLowerCase()).to.equal 'div'
      expect(nod.node._nod).to.equal nod

    it "should create element only once", ->
      nod = Nod.create()
      nod2 = Nod.create(nod)
      nod3 = Nod.create(nod.node)
      expect(nod).to.equal nod2
      expect(nod2).to.equal nod3
      expect(nod3).to.equal nod



  describe "instance functions", ->

    test_root = Nod.create()
    Nod.root.append test_root.node

    beforeEach ->
      @test_div = Nod.create()
      test_root.node.appendChild(@test_div.node)

    afterEach ->
      test_root.html('')
  
    it "should find element", ->
      @test_div.html('<a href="#">1</a><span class="a">2</span><span id="b">3</span>')
      expect(@test_div.find('a').textContent).to.equal "1"
      expect(@test_div.find('.a').textContent).to.equal "2"
      expect(@test_div.find('#b').textContent).to.equal "3"

    it "should find only one element", ->
      @test_div.html('<a href="#">1</a><a href="#">2</a>')
      expect(@test_div.find('a').textContent).to.equal "1"

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

    it "should clone", ->
      @test_div.html '<span>Hi!</span>'
      a = @test_div.clone()
      @test_div.insertAfter a
      @test_div.html '<span>Hello!</span>'
      expect(test_root.html()).to.equal '<div><span>Hello!</span></div><div><span>Hi!</span></div>'