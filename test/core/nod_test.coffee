'use strict'
h = require 'pieces-core/test/helpers'

describe "Nod", ->
  root = h.test_cont(pi.Nod.body)

  before ->
    h.mock_raf()
  after ->
    h.unmock_raf()
    root.remove()

  Nod = pi.Nod

  describe "class functions", ->
    it "create element", ->
      nod = Nod.create 'div'
      expect(nod.node.nodeName.toLowerCase()).to.equal 'div'
      expect(pi.Nod.fetch(nod.node._nod)).to.equal nod

    it "create element only once", ->
      nod = Nod.create 'div'
      nod2 = Nod.create nod
      nod3 = Nod.create nod.node
      expect(nod).to.equal nod2
      expect(nod2).to.equal nod3
      expect(nod3).to.equal nod

    it "return null argument passed but null", ->
      nod = Nod.create null
      expect(nod).to.be.null

    it "create element with tag", ->
      nod = Nod.create 'a'
      expect(nod.node.nodeName.toLowerCase()).to.equal 'a'

    it "create element with html content", ->
      nod = Nod.create '<a href="@test">Test</a>'
      expect(nod.node.nodeName.toLowerCase()).to.equal 'a'
      expect(nod.attr('href')).to.equal '@test'
      expect(nod.text()).to.equal 'Test'


  describe "instance functions", ->
    it "find element", ->
      test_div = h.test_cont(root, '<div><a href="#">1</a><span class="a">2</span><span id="b">3</span></div>')
      expect(test_div.find('a').text()).to.equal "1"
      expect(test_div.find('.a').text()).to.equal "2"
      expect(test_div.find('#b').text()).to.equal "3"

    it "find only one element", ->
      test_div = h.test_cont(root, '<div><a href="#">1</a><a href="#">2</a></div>')
      expect(test_div.find('a').text()).to.equal "1"

    it "return children (equal size)", ->
      test_div = h.test_cont(root, '<div><a href="#">1</a><a href="#">2</a></div>')
      expect(test_div.children().length).to.equal 2

    it "work with each", ->
      test_div = h.test_cont(root, '<div><a class="a" href="#">1</a><div><span class="a">2</span></div><span class="a">3</span></div>')
      r = ""
      test_div.each('.a', (node) -> r+= node.textContent)
      expect(r).to.equal "123"

    it "append child", ->
      test_div = h.test_cont(root, '<div><span>0</span></div>')
      a = Nod.create 'a'
      a.text '1'
      test_div.append a
      expect(test_div.html()).to.equal '<span>0</span><a>1</a>'

    it "prepend child", ->
      test_div = h.test_cont(root, '<div><span>0</span></div>')
      a = Nod.create 'a'
      a.text '1'
      test_div.prepend a
      expect(test_div.html()).to.equal '<a>1</a><span>0</span>'

    it "append html string", ->
      test_div = h.test_cont(root, '<div><span>0</span></div>')
      test_div.append '<a>1</a>'
      expect(test_div.html()).to.equal '<span>0</span><a>1</a>'

    it "insert element after", ->
      test_div = h.test_cont(root, '<div><span>0</span></div>')
      a = Nod.create 'a'
      a.text '1'
      span = test_div.find('span')
      span.insertAfter a
      expect(test_div.html()).to.equal '<span>0</span><a>1</a>'

    it "insert element before", ->
      test_div = h.test_cont(root, '<div><span>0</span></div>')
      a = Nod.create 'a'
      a.text '1'
      span = test_div.find('span')
      span.insertBefore a
      expect(test_div.html()).to.equal '<a>1</a><span>0</span>'

    it "insert element before as string", ->
      test_div = h.test_cont(root, '<div><span>0</span></div>')
      span = test_div.find('span')
      span.insertBefore '<a>1</a>'
      expect(test_div.html()).to.equal '<a>1</a><span>0</span>'


    it "wrap itself", ->
      test_div = h.test_cont(root)
      target = pi.Nod.create 'div'
      test_div.append target
      expect(test_div.html()).to.equal '<div></div>'
      target.wrap()
      expect(test_div.html()).to.equal '<div><div></div></div>'

    it "find parent", ->
      test_div = h.test_cont(root, '<div><span>0</span></div>')
      sp = test_div.find('span')
      expect(sp.parent()).to.eq test_div

    it "return null if no parent", ->
      sp = Nod.create('<span>0</span>')
      expect(sp.parent()).to.be.null

    it "find parent by selector", ->
      test_div = h.test_cont(root, '<div class="pi"><div class="a"><div class="b"><span>1</span></div></div></div>')
      sp = test_div.find('span')
      dv = test_div.find('.a')
      dv2 = test_div.find('.b')
      expect(sp.parent('.a')).to.eq dv
      expect(sp.parent('.b')).to.eq dv2
      expect(sp.parent('.pi')).to.eq test_div


    it "not find parent by selector", ->
      test_div = h.test_cont(root)
      expect(test_div.parent('.abcd')).to.be.null


    it "find children by selector", ->
      test_div = h.test_cont(root, '<div><div class="a"><div class="b"><span class="a">1</span></div></div></div>')
      expect(test_div.children('.a')).to.have.length 1

    it "merge classes", ->
      a = pi.Nod.create '<span class="a c d"></span>'
      b = pi.Nod.create '<span class="a b"></span>'
      a.mergeClasses b
      expect(a.hasClass('a')).to.be.true
      expect(a.hasClass('b')).to.be.true
      expect(a.hasClass('c')).to.be.true
      expect(a.hasClass('d')).to.be.true


    it "clone", ->
      test_div = h.test_cont(root)
      sp = pi.Nod.create '<span>Hi!</span>'
      test_div.append sp
      sp2 = sp.clone()
      sp.insertAfter sp2
      sp.text 'Hello!'
      expect(test_div.html()).to.equal '<span>Hello!</span><span>Hi!</span>'

    describe 'hash functions', ->
      test_div = null
      before ->
        test_div = h.test_cont root, """
          <div data-a="1" data-b="2" data-long-name="3" style="color:black;position:relative" class="test example">
            <input type="text" value="1"/>
          </div>
          """
      it "read serialized data attributes", ->
        expect(test_div.data('a')).to.equal 1
        expect(test_div.data('long-name')).to.equal 3
        expect(test_div.data()).to.eql {a: 1, b: 2, long_name: 3}

      it "write data attributes", ->
        test_div.data('a', '11')
        expect(test_div.data('a')).to.equal '11'
        test_div.data('c', '22')
        expect(test_div.data('c')).to.equal '22'
        test_div.data('is-d', '22')
        expect(test_div.data('is_d')).to.equal '22'

  describe "NodRoot", ->
    it "ready", (done) ->
      Nod.root.ready().then(
        ->
          Nod.root.ready()
      ).then(done)

    it "loaded", (done) ->
      Nod.root.loaded().then(
        ->
          Nod.root.loaded()

      ).then(done)
