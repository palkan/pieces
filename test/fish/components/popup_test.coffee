'use strict'
TestHelpers = require '../helpers'

describe "popup component", ->
  Nod = pi.Nod
  root = Nod.create 'div'
  Nod.body.append root.node
  utils = pi.utils

  beforeEach ->
    test_div = Nod.create('div')
    test_div.style position:'relative'
    root.append test_div 
    test_div.append '''
        <div class="pi pi-popup" data-pid="popup" data-z="100" data-hide-delay="200" data-show-delay="0">
        </div>
        '''
    pi.app.view.piecify()
    @popup = $('@popup')

  afterEach ->
    @popup.remove()
  
  describe "initialization", ->
    it "should init as Popup", ->
      expect(@popup).to.be.an.instanceof pi.PopupContainer

    it "should init params", ->
      expect(@popup.z).to.eq 100
      expect(@popup.show_delay).to.eq 0
      expect(@popup.hide_delay).to.eq 200

  describe "add popups", ->
    it "should create overlay and container with popup", ->
      p = pi.Nod.create('div')
      p.node.id = _id = "id#{utils.uid()}" 
      root.append p
      @popup.open p
      expect(@popup.children()).to.have.length 2
      expect(@popup.children('.pi-overlay')).to.have.length 1
      expect(@popup.children('.pi-popup-container')).to.have.length 1
      expect(root.all("##{_id}")).to.have.length 1


    it "should remove popup on close", (done) ->
      p = pi.Nod.create('div')
      @popup.open p
      # wait for open
      after 100, =>
        TestHelpers.clickElement @popup.find('.pi-overlay').node
        after 300, =>
          expect(@popup.children()).to.have.length 0
          expect(p._disposed).to.be.true
          done()

    it "should add several popups", (done) ->
      @popup.open pi.Nod.create('div')
      @popup.open pi.Nod.create('div')
      @popup.open pi.Nod.create('div')
      @popup.open pi.Nod.create('div')

      expect(@popup.children()).to.have.length 8
      expect(@popup.find('.pi-overlay').enabled).to.be.false

      @popup.close().then( => @popup.close().then( 
        => @popup.close().then(=> 
          @popup.close().then(
            =>
              expect(@popup.children()).to.have.length 0
              done()
            ))))

  describe "close options", ->
    it "should handle many clicks", (done) ->
      p = pi.Nod.create('div')
      @popup.open p
     # wait for open
      after 100, =>
        expect(@popup.children()).to.have.length 2
        TestHelpers.clickElement @popup.find('.pi-overlay').node
        TestHelpers.clickElement @popup.find('.pi-overlay').node
        TestHelpers.clickElement @popup.find('.pi-overlay').node
        after 300, =>
          expect(@popup.children()).to.have.length 0
          done()        


    it "should not close", (done) ->
      p = pi.Nod.create('div')
      @popup.open p, close: false
     # wait for open
      after 100, =>
        expect(@popup.children()).to.have.length 2
        TestHelpers.clickElement @popup.find('.pi-overlay').node
        after 300, =>
          expect(@popup.children()).to.have.length 2
          done()        

    it "should call function before close", (done) ->
      p = pi.Nod.create('div')

      fun = => 
        after 400, =>
          expect(@popup.children()).to.have.length 0
          done()

      @popup.open p, close: fun
     # wait for open
      after 100, =>
        expect(@popup.children()).to.have.length 2
        TestHelpers.clickElement @popup.find('.pi-overlay').node

    it "should call function different fucntions for different popups", (done) ->
      fun = sinon.spy()
      @popup.open pi.Nod.create('div'), close: fun
      
      fun2 = sinon.spy()    
      @popup.open pi.Nod.create('div'), close: fun2
      
      # wait for open
      after 100, =>
        expect(@popup.children()).to.have.length 4
        TestHelpers.clickElement @popup.find('.pi-overlay').node
        after 300, =>
          TestHelpers.clickElement @popup.find('.pi-overlay').node
          after 300, =>
            expect(@popup.children()).to.have.length 0
            expect(fun.callCount).to.eq 1
            expect(fun2.callCount).to.eq 1
            done()