'use strict'
TestHelpers = require './helpers'

describe "Pieces RVC", ->
  TestUsers = pi.resources.TestUsers
  Controller = pi.controllers.Test
  utils = pi.utils

  Nod = pi.Nod
  root = Nod.create 'div'
  Nod.body.append root.node

  (window.JST||={})['test/user'] = (data) ->
    nod = Nod.create("<div>#{ data.name }</div>")
    nod.addClass 'item'
    nod.append "<span class='age'>#{ data.age }</span>"
    nod  

  page = pi.app.page

  describe "rvc app test", ->

    beforeEach (done) ->
      @test_div = Nod.create 'div'
      @test_div.style position:'relative'
      root.append @test_div 
      @test_div.append """
        <div class="pi" data-component="test_view" data-main="true" data-controller="test3" pid="test" style="position:relative">
          <div>
            <h1 class="pi" pid="title"></h1> 
          </div>
          <input class="pi" pid="search" type="text" value="" data-on-change="@@search(@this.value)"/>
          <div class="progress-wrapper">
            <div class="pi pi-progressbar" pid="loader"></div>
          </div>
          <div class="pi pi-action-list" data-renderer="jst(test/user)" data-listen-create="true" data-plugins="restful" data-rest="test_users" pid="list">
            <ul class="list">
            </ul>
          </div> 
        </div>
        <div class="pi" data-component="test2_view" pid="test" style="position:relative">
          <div class="pi pi-text-input-wrap" pid="input_txt">
            <input type="text" value=""/>
          </div>
          <button class="pi" data-on-click="@@submit(@view.input_txt.value)"></button> 
        </div>
      """
      pi.app.initialize().then(
        =>
          @t = page._contexts.test
          @t2 = page._contexts.test2
          done()
      )

    afterEach ->
      @test_div.remove()
      page.dispose()
      TestUsers.clear_all()
      TestUsers.off()

    describe "initialization", ->
      it "should load users", (done) ->
        @t.index().then( =>
          expect(@t.view.list.size()).to.eq 15
          done()
        )

    describe "switching", ->
      it "should switch with data", (done) ->
        expect(page.context).to.eq @t
        @t.switch('test2').then(
          =>
            expect(page.context).to.eq @t2
            @t2.view.input_txt.value('bla-bla')

            TestHelpers.clickElement @t2.view.find('button').node

            new Promise( (resolve) =>
              utils.after 100, =>
                expect(page.context_id).to.eq 'test'
                expect(page.context).to.eq @t
                expect(@t.view.title.text()).to.eq 'bla-bla'
                resolve page.switch_back()
            )
        ).then(
          =>
            expect(page.context_id).to.eq 'test'
            done()
        ).catch(
          (e) => done(e)
        )

     describe "querying", ->
      it "should return search data", (done) ->
        expect(page.context).to.eq @t
        @t.view.search.value('jo')

        @t.view.search.trigger('change')
        after 1000, =>
          expect(@t.view.list.size()).to.eq 3
          done()     

      it "should return sort data", (done) ->
        @t.sort([{age: 'asc'}]).then(
          =>
            expect(@t.view.list.items[0].record.name).to.eq 'luiza'
            done()
          )   

      it "should return filter data", (done) ->
        @t.filter(age: 33).then(
          =>
            expect(@t.view.list.size()).to.eq 4
            done()  
        )

      it "should work with series", (done) ->
        @t.search('k').then(
          =>
            expect(@t.view.list.size()).to.eq 5
            expect(@t.view.list.searchable.searching).to.be.true
            @t.filter(age:21).then(
              =>
                expect(@t.view.list.size()).to.eq 3
                expect(@t.view.list.searchable.searching).to.be.true
                @t.sort([{name: 'asc'}]).then(
                  => 
                    expect(@t.view.list.size()).to.eq 3
                    expect(@t.view.list.searchable.searching).to.be.true
                    expect(@t.view.list.items[0].record.name).to.eq 'klara'
                    done()
                )
            )          
        )

      it "should work with queued series", (done) ->
        @t.search('k')
        @t.filter(age:21)
        @t.sort([{name: 'asc'}]).then(
          => 
            expect(@t.view.list.size()).to.eq 3
            expect(@t.view.list.searchable.searching).to.be.true
            expect(@t.view.list.items[0].record.name).to.eq 'klara'
            done()
        )


      it "should work with series (and clear scope)", (done) ->
        @t.filter(age: 33).then(
          =>
            expect(@t.view.list.size()).to.eq 4
            expect(@t.view.list.searchable.searching).to.be.false
            @t.search('h').then(
              =>
                expect(@t.view.list.size()).to.eq 3
                expect(@t.view.list.searchable.searching).to.be.true
                expect(@t.view.list.filterable.filtered).to.be.true
                @t.filter(null).then(
                  => 
                    expect(@t.view.list.size()).to.eq 5
                    expect(@t.view.list.searchable.searching).to.be.true
                    expect(@t.view.list.filterable.filtered).to.be.false
                    @t.search('').then(
                      =>
                        expect(@t.view.list.size()).to.eq 15
                        expect(@t.view.list.searchable.searching).to.be.false
                        expect(@t.view.list.filterable.filtered).to.be.false
                        done()
                    )
                )
            )          
        )

    describe "REST", ->
      it "should return item data", (done) ->
        @t.users.find(3).then(
          (data) ->
            expect(data.id).to.eq 3
            done()
        )

      it "should not return item data if no such item", (done) ->
        @t.users.find(0).then(
          (data) ->
            utils.error data
        ).catch(
          (e) ->
            expect(e.message).to.eq 'Not found'
            done()
        )

      it "should not create item data if data is wrong", (done) ->
        @t.users.create({age: 1}).then(
          (data) ->
            utils.error data
        ).catch(
          (e) ->
            expect(e.message).to.eq 'name is missing'
            done()
        )


      it "should create item", (done) ->
        was = @t.view.list.size()
        @t.users.create({name:'vasya', age: 25}).then(
          (data) =>
            expect(data.name).to.eq 'vasya'
            expect(data.age).to.eq 25
            expect(@t.view.list.size()).to.eq was+1
            done()
        ).catch(
          (e) ->
            utils.error e
        )

      it "should destroy item", (done) ->
        @t.index().then(
          => 
            was = @t.view.list.size()
            @t.users.all()[0].destroy().then(
              (data) =>
                expect(@t.view.list.size()).to.eq was-1
                done()
            )
        ).catch(
          (e) ->
            utils.error e
        )

      it "should update item", (done) ->
        @t.sort([{age: 'desc'}]).then(
          => 
            was = @t.view.list.size()
            item = @t.view.list.items[was-1].record
            item.update({age: 100}).then(
              (data) =>
                after 500, =>
                  expect(@t.view.list.size()).to.eq was
                  expect(@t.view.list.items[0].record.age).to.eq 100
                  done()
            )
        ).catch(
          (e) ->
            utils.error e
        )
