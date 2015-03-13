'use strict'
h = require 'pi/test/helpers'
utils = pi.utils
Nod = pi.Nod

describe "List.JST", ->
  root = h.test_cont(pi.Nod.body)

  after ->
    root.remove()

  test_div = list = null

  beforeEach ->
    test_div = Nod.create('div')
    test_div.style position:'relative'
    root.append test_div
    window.JST ||= {}

    window.JST['test/item'] = (data) ->
      nod = Nod.create("<div>#{ data.name }</div>")
      nod.addClass 'item'
      nod.append "<span class='author'>#{ data.author }</span>"
      nod  

    test_div.append """
        <div class="pi" data-component="list" data-renderer="jst(test/item)"  data-pid="test" style="position:relative">
          <ul class="list">
          </ul>
        </div>
      """
    pi.app.view.piecify()

      

    list = test_div.find('.pi')

  afterEach ->
    test_div.remove()

  
  it "render elements", ->
    list.data_provider [ 
      {id:1, name: 'Element 1', author: 'John'},
      {id:2, name: 'Element 2', author: 'Bob'},
      {id:3, name: 'Element 3', author: 'John'} 
    ]
    expect(list.all('.item').length).to.equal 3
    expect(list.first('.author').text()).to.equal 'John'
    expect(list.items[2].html()).to.equal 'Element 3<span class="author">John</span>'



describe "List.JST (simple template)", ->
  root = h.test_cont(pi.Nod.body)

  after ->
    root.remove()

  test_div = list = list2 = null

  beforeEach ->
    test_div = Nod.create('div')
    test_div.style position:'relative'
    root.append test_div

    test_div.append """
        <div class="pi test" data-component="list" data-pid="test" style="position:relative">
          <ul class="list">
            <script type="text/html" class="pi-renderer">
              <li class="item">
                {{ name }}<span>{{ $num }}</span>
              </li>
            </script>
          </ul>
        </div>
        <div class="pi test2" data-component="list" data-pid="test2" style="position:relative">
          <ul class="list">
            <script type="text/html" class="pi-renderer">
              <li class="item {? active ? 'is-active' ?}">
                {? size > 10 ? '10+' : size ?}
                {> tags }
                  <span class="tag">{{ name }}</span>
                {< tags }
              </li> 
            </script>
          </ul>
        </div>
      """
    pi.app.view.piecify()

    list = test_div.find('.test')
    list2 = test_div.find('.test2')

  afterEach ->
    test_div.remove()

  
  it "render elements", ->
    list.data_provider [ 
      {id:1, name: 'Element 1', size: 0, active: false},
      {id:2, name: 'Element 2', size: 100, active: true},
      {id:3, name: 'Element 3'} 
    ]
    expect(list.all('.item').length).to.equal 3
    expect(list.first('span').text()).to.equal '1'
    expect(list.items[2].html()).to.equal 'Element 3<span>2</span>'

  it "render elements with conditions", ->
    list2.data_provider [ 
      {id:1, name: 'Element 1', size: 0, active: false},
      {id:2, name: 'Element 2', size: 100, active: true},
      {id:3, name: 'Element 3', tags: ['a','b']} 
    ]
    expect(list2.all('.item').length).to.equal 3
    expect(list2.first('.is-active').text()).to.equal '10+'
    expect(list2.items[0].html()).to.equal '0'
    expect(list2.items[2].html()).to.equal '<span class="tag">a</span><span class="tag">b</a>'
