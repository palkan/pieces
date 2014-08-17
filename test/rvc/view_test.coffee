'use strict'
TestHelpers = require './helpers'

describe "pi calls with view", ->
  Nod = pi.Nod
  root = Nod.create 'div'
  Nod.body.append root.node

  beforeEach ->
    @test_div = Nod.create 'div'
    @test_div.style position:'relative'
    root.append @test_div 

    @test_div.append('''
      <div class="pi" data-pid="test" data-component="view.base">
        <span pid="btn" class="pi" data-on-click="@this.view.log.text('bla')"></span>
        <span pid="log" class="pi">loggo</span>
      </div>
      ''')
    pi.app.view.piecify()
    @example = $("@test")

  
  afterEach ->
    root.html ''

  it "should work with bool condition", ->
    TestHelpers.clickElement @example.btn.node
    expect(@example.log.text()).to.eq 'bla'
