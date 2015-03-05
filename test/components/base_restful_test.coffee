'use strict'
h = require 'pi/test/helpers'
utils = pi.utils
Nod = pi.Nod
TestUsers = pi.resources.TestUsers
Controller = pi.controllers.Test

describe "Base.Restful", ->
  root = h.test_cont(pi.Nod.body)

  after ->
    root.remove()

  test_div = example = page = null

  beforeEach ->
    (window.JST||={})['test/user'] = (data) ->
      nod = Nod.create("<div>#{ data.name }</div>")
      nod.addClass 'item'
      nod.append "<span class='age'>#{ data.age }</span>"
      nod  

    page = pi.app.page

    test_div = Nod.create('div')
    test_div.style position:'relative'
    root.append test_div

  afterEach ->
    test_div.remove()
    TestUsers.clear_all()
    TestUsers.off()

  it "bind app resource on init", (done) ->
    pi.app.user = TestUsers.build({name: 'Lee', age: 44})
    test_div.append """
      <div class="pi" pid="test" data-plugins="restful" data-renderer="jst(test/user)" data-rest="app.user">
      </div>
    """
    
    test_div.piecify()

    example = test_div.find('.pi') 
    utils.after 100, ->
      expect(example.restful.resource).to.eq pi.app.user
      done()

  it "bind resource after init", ->
    test_div.append """
      <div class="pi" pid="test" data-plugins="restful" data-renderer="jst(test/user)">
      </div>
    """

    test_div.piecify()
    example = test_div.find('.pi') 

    pi.app.user = TestUsers.build({name: 'Lee', age: 44})
    example.restful.bind pi.app.user, true

    expect(example.find('.age').text()).to.eq '44'

    pi.app.user.set age: 45
    expect(example.find('.age').text()).to.eq '45'

  it "bind remote resource", (done) ->
    test_div.append """
      <div class="pi" pid="test" data-plugins="restful" data-renderer="jst(test/user)" data-rest="TestUsers.find(2)">
      </div>
    """
    test_div.piecify()
    example = test_div.find('.pi') 

    utils.after 300, ->
      expect(example.find('.age').text()).to.eq '12'
      TestUsers.get(2).set age: 13
      expect(example.find('.age').text()).to.eq '13'
      done()