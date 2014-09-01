'use strict'
TestHelpers = require '../rvc/helpers'

describe "Restful List", ->
  Testo= pi.resources.Testo
  View = pi.resources.View
  utils = pi.utils

  Nod = pi.Nod
  root = Nod.create 'div'
  Nod.body.append root.node

  (window.JST||={})['test/testo'] = (data) ->
    nod = Nod.create("<div>#{ data.type }</div>")
    nod.addClass 'item'
    nod.append "<span class='salt'>#{ data.salt_id }</span>"
    nod  

  describe "restful list with params", ->

    beforeEach ->
      Testo.load [
        {id:1, type: 'puff', salt_id: 2},
        {id:2, type: 'gut', salt_id: 1},
        {id:3, type: 'bett', salt_id: 2},
        {id:4, type: 'yeast', salt_id: 1},
        {id:5, type: 'sweet', salt_id: 2},
        {id:6, type: 'donut', salt_id: 1}  
      ]
      @test_div = Nod.create 'div'
      @test_div.style position:'relative'
      root.append @test_div 
      @test_div.append """
        <div class="pi pi-action-list" data-renderer="jst(test/testo)" data-plugins="restful" data-load-rest="true" data-rest="testo.where(salt_id:1)" pid="list">
          <ul class="list">
          </ul>
        </div> 
      """
      pi.app.initialize()
      @list = $("@list")

    afterEach ->
      @test_div.remove()
      Testo.off()
      Testo.clear_all()

    describe "initialization", ->
      it "should load elements on initialize", ->
        expect(@list.size()).to.eq 3

    describe "CRUD", ->
      it "should add element", ->
        Testo.build(type:'dirt',id:7, salt_id: 1)
        expect(@list.size()).to.eq 4
        expect(@list.items[@list.size()-1].record.type).to.eq 'dirt'

      it "should not add element if it doesn't match", ->
        Testo.build(type:'dirt',id:7, salt_id: 2)
        expect(@list.size()).to.eq 3

      it "should remove element", ->
        Testo.remove_by_id(2)
        expect(@list.size()).to.eq 2

      it "should not remove element if it doesn't match", ->
        Testo.remove_by_id(1)
        expect(@list.size()).to.eq 3

  describe "restful list with view", ->

    beforeEach ->
      Testo.load [
        {id:1, type: 'puff', salt_id: 2},
        {id:2, type: 'gut', salt_id: 1},
        {id:3, type: 'bett', salt_id: 2},
        {id:4, type: 'yeast', salt_id: 1},
        {id:5, type: 'sweet', salt_id: 2},
        {id:6, type: 'donut', salt_id: 1}  
      ]
      @test_div = Nod.create 'div'
      @test_div.style position:'relative'
      root.append @test_div 
      @test_div.append """
        <div class="pi pi-action-list" data-renderer="jst(test/testo)" data-plugins="restful"  pid="list">
          <ul class="list">
          </ul>
        </div> 
      """
      pi.app.initialize()
      @view = new View(Testo, salt_id: 1)
      @view.build Testo.get(2)
      @list = $("@list")
      @list.restful.bind @view, true

    afterEach ->
      @test_div.remove()
      Testo.off()
      Testo.clear_all()
      @view.clear_all()
      @view.off()

    describe "initialization", ->
      it "should load elements on bind", ->
        expect(@list.size()).to.eq 1

    describe "CRUD", ->
      it "should add element", ->
        @view.build(type:'dirt',id:7, salt_id: 1)
        expect(@list.size()).to.eq 2
        expect(@list.items[@list.size()-1].record.type).to.eq 'dirt'

      it "should remove element", ->
        Testo.remove_by_id(2)
        expect(@list.size()).to.eq 0

      it "should not remove element if it doesn't match", ->
        Testo.remove_by_id(1)
        expect(@list.size()).to.eq 1

