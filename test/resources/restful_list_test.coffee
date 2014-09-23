'use strict'
TestHelpers = require '../rvc/helpers'

describe "Restful List", ->
  Testo= pi.resources.Testo
  View = pi.resources.View
  utils = pi.utils
  Chef = pi.resources.Chef
  Testo2 = pi.Testo2

  Nod = pi.Nod
  root = Nod.create 'div'
  Nod.body.append root.node

  (window.JST||={})['test/testo'] = (data) ->
    nod = Nod.create("<div class='type'>#{ data.type }</div>")
    nod.addClass 'item'
    nod.append "<span class='salt'>#{ data.salt_id||'' }</span>"
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
        <div class="pi pi-action-list" data-renderer="jst(test/testo)" data-plugins="restful" data-load-rest="true" data-rest="testo.where(salt_id:1)" data-listen-load="true" pid="list">
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

      it "should reload elements on unbind-bind", ->
        expect(@list.size()).to.eq 3
        @list.restful.bind null
        @list.restful.bind Testo, true, salt_id:1
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

      it "should load elements", ->
        Testo.load([{type:'dirt',id:7, salt_id: 1},{type:'sqrrt',id:8, salt_id: 2}])
        expect(@list.size()).to.eq 4

      it "should not load elements if they exist", ->
        Testo.load([{type:'dirt',id:2, salt_id: 1},{type:'sqrrt',id:4, salt_id: 1}])
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


  describe "restful list with association", ->

    beforeEach ->
      Chef.load [{id:1}]
      Testo2.load [
        {id:1, type: 'puff', chef_id: 2},
        {id:2, type: 'gut', chef_id: 1},
        {id:3, type: 'bett', chef_id: 2},
        {id:4, type: 'yeast', chef_id: 1},
        {id:5, type: 'sweet', chef_id: 2},
        {id:6, type: 'donut', chef_id: 1}  
      ]
      @test_div = Nod.create 'div'
      @test_div.style position:'relative'
      root.append @test_div 
      @test_div.append """
        <div class="pi pi-action-list" data-renderer="jst(test/testo)" data-rest="Chef.find(1).testos" data-plugins="restful" data-load-rest="true" pid="list">
          <ul class="list">
          </ul>
        </div> 
      """
      pi.app.initialize()
      @chef = Chef.get(1)
      @list = $("@list")

    afterEach ->
      @list.off()
      Testo2.off()
      Testo2.clear_all()
      Chef.clear_all()
      Chef.off()
      @test_div.remove()

    describe "initialization", ->
      it "should load elements on bind", ->
        expect(@list.size()).to.eq 3

    describe "CRUD", ->
      it "should add element", ->
        @chef.testos().build(type:'dirt',id:7)
        expect(@list.size()).to.eq 4
        expect(@list.items[@list.size()-1].record.type).to.eq 'dirt'

      it "should remove element", ->
        Testo2.remove_by_id(2)
        expect(@list.size()).to.eq 2

      it "should not remove element if it doesn't match", ->
        Testo2.remove_by_id(1)
        expect(@list.size()).to.eq 3


  describe "restful list with temporary association", ->
    beforeEach ->
      Testo2.load [
        {id:1, type: 'puff', chef_id: 2},
        {id:2, type: 'gut', chef_id: 1},
        {id:3, type: 'bett', chef_id: 2},
        {id:4, type: 'yeast', chef_id: 1},
        {id:5, type: 'sweet', chef_id: 2},
        {id:6, type: 'donut', chef_id: 1}  
      ]
      @test_div = Nod.create 'div'
      @test_div.style position:'relative'
      root.append @test_div 
      @test_div.append """
        <div class="pi pi-action-list" data-renderer="jst(test/testo)" data-plugins="restful" pid="list">
          <ul class="list">
          </ul>
        </div> 
      """
      @chef = Chef.build name: 'Julio'
      @testo = @chef.testos().build type: 'yaws'
      pi.app.initialize()
      @list = $("@list")

    afterEach ->
      @list.off()
      Testo2.off()
      Testo2.clear_all()
      Chef.clear_all()
      Chef.off()
      @test_div.remove()

    describe "initialization", ->
      it "should load elements on bind", ->
        @list.restful.bind @chef.testos(), true
        expect(@list.size()).to.eq 1
        expect(@list.items[0].record.id).to.eq @testo.id

    describe "CRUD", ->
      beforeEach ->
        @list.restful.bind @chef.testos(), true

      it "should add element", ->
        @chef.testos().build(type:'dirt')
        expect(@list.size()).to.eq 2
        expect(@list.items[@list.size()-1].record.type).to.eq 'dirt'
        expect(@list.last('.type').text()).to.eq 'dirt'

      it "should remove element", ->
        @chef.testos().remove @testo
        expect(@list.size()).to.eq 0

      it "should not remove element if it doesn't match", ->
        Testo2.remove_by_id(1)
        expect(@list.size()).to.eq 1

      it "should update element on create", ->
        @testo.set type: 'yeast', id: 123
        expect(@list.size()).to.eq 1
        expect(@list.items[@list.size()-1].record.type).to.eq 'yeast'
        expect(@list.items[@list.size()-1].record.id).to.eq 123
        expect(@list.find('.type').text()).to.eq 'yeast'

      it "should update element on update", ->
        @testo.set type: 'yeast'
        expect(@list.size()).to.eq 1
        expect(@list.items[@list.size()-1].record.type).to.eq 'yeast'
        expect(@list.find('.type').text()).to.eq 'yeast'

      it "should load elements on owner create", ->
        @chef.set id: 5
        expect(@list.size()).to.eq 1
        expect(@list.items[@list.size()-1].record.chef_id).to.eq 5




