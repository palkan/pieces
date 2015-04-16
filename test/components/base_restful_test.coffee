'use strict'
h = require 'pieces-core/test/helpers'
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
    page = pi.app.page

    test_div = Nod.create('div')
    test_div.style position:'relative'
    root.append test_div

  afterEach ->
    test_div.remove()
    TestUsers.clear_all()
    TestUsers.off()

  it "bind app resource on init", ->
    pi.app.user = TestUsers.build({name: 'Lee', age: 44})
    test_div.append """
      <div class="pi" pid="test" data-bind-render="app.user">
        <script type="text/html" class="pi-renderer">
          {{ name }}
          <span class='age'>{{ age }}</span>
        </script>
      </div>
    """
    
    test_div.piecify()

    example = test_div.find('.pi') 
    expect(example.find('.age').text()).to.eq '44'
    expect(example.text()).to.contain 'Lee'

  it "bind resource after init", ->
    test_div.append """
      <div class="pi" pid="test">
        <script type="text/html" class="pi-renderer">
          {{ name }}
          <span class='age'>{{ age }}</span>
        </script>
      </div>
    """

    test_div.piecify()
    example = test_div.find('.pi') 

    pi.app.user = TestUsers.build({name: 'Lee', age: 44})
    example.bind 'render', 'pi.app.user'

    expect(example.find('.age').text()).to.eq '44'
    expect(example.text()).to.contain 'Lee'

    pi.app.user.set age: 45
    expect(example.find('.age').text()).to.eq '45'

  it "bind resource by id", ->
    TestUsers.build id: 2, name: 'Karl', age: 12
    test_div.append """
      <div class="pi" pid="test" data-bind-render="TestUsers(2)">
        <script type="text/html" class="pi-renderer">
          {{ name }}
          <span class='age'>{{ age }}</span>
        </script>
      </div>
    """
    test_div.piecify()
    example = test_div.find('.pi') 

    expect(example.find('.age').text()).to.eq '12'
    expect(example.text()).to.contain 'Karl'
    
    TestUsers.get(2).set age: 13
    expect(example.find('.age').text()).to.eq '13'

  it "unbinds and clears contents", ->
    pi.app.user = TestUsers.build({name: 'Lee', age: 44})
    test_div.append """
      <div class="pi" pid="test" data-bind-render="app.user">
        <script type="text/html" class="pi-renderer">
          {{ name }}
          <span class='age'>{{ age }}</span>
        </script>
      </div>
    """
    
    test_div.piecify()

    example = test_div.find('.pi') 
    expect(example.find('.age').text()).to.eq '44'
    expect(example.text()).to.contain 'Lee'

    example.unbind('render', 'app.user')
    expect(example.text().trim()).to.eq ''
