describe "text input component", ->
  Nod = pi.Nod
  root = Nod.create 'div'
  Nod.body.append root.node

  beforeEach ->
    @test_div = Nod.create 'div'
    @test_div.style position:'relative'
    root.append @test_div 
    @test_div.append """
        <div class="pi text-input" data-pid="test" style="position:relative">
          <input type="text" value="1"/>
        </div>
        <input class="pi is-readonly" data-pid="test2" type="text" value="2"/>
      """
    pi.app.initialize()
    @test1 = $('@test')
    @test2 = $('@test2')

  afterEach ->
    @test_div.remove()

  describe "editable", ->

    it "should trigger event on readonly", (done) ->
      @test1.on 'editable', (e) =>
        expect(e.data).to.be.false
        expect(@test1.editable).to.be.false
        done()

      @test1.readonly()

    it "should init as readonly", ->
      expect(@test2.editable).to.be.false

    it "should trigger event on edit", (done) ->
      @test2.on 'editable', (e) =>
        expect(e.data).to.be.true
        expect(@test2.editable).to.be.true
        done()

      @test2.edit()