describe "button component", ->
  beforeEach ->
    @test_div = $(document.createElement('div'))
    @test_div.css position:'relative'
    $('body').append(@test_div)

  afterEach ->
    @test_div.remove()

  describe "click option", ->
    beforeEach  ->
      @test_div.append('<div class="pi" data-component="test_component" data-pi="test" style="position:relative"></div>')
      @test_div.append('<button class="pi" data-component="button" data-pi="btn" data-event-click="@test.hide" style="position:relative">Button</button>')
      pi.piecify()

    it "should call method on click", ->
      TestHelpers.clickElement $('@btn').get(0)
      expect($('@test').pi().visible).to.be.false