describe "jst renderer list plugin", ->
  beforeEach ->
    window.JST = {}

    window.JST['test/item'] = (data) ->
      nod = $("<div>#{ data.name }</div>")
      nod.addClass 'item'
      nod.append "<span class='author'>#{ data.author }</span>"
      nod  

    @test_div = $(document.createElement('div'))
    @test_div.css position:'relative'
    $('body').append(@test_div)
    @test_div.append """
        <div class="pi" data-component="list" data-option-renderer="test/item" data-plugins="jst_renderer" data-pi="test" style="position:relative">
          <ul class="list">
          </ul>
        </div>
      """
    pi.piecify()

      

    @list = $('@test').pi()

  afterEach ->
    @test_div.remove()

  describe "render template", ->
    
    it "should render elements with jst template", ->
      @list.data_provider [ 
        {id:1, name: 'Element 1', author: 'John'},
        {id:2, name: 'Element 2', author: 'Bob'},
        {id:3, name: 'Element 3', author: 'John'} 
      ]
      expect(@list.nod.find('.item').size()).to.equal 3
      expect(@list.nod.find('.author').first().text()).to.equal 'John'
      expect(@list.items[2].nod.html()).to.equal 'Element 3<span class="author">John</span>'