describe "guesser test", ->
  Nod = pi.Nod
  root = Nod.create 'div'
  Nod.body.append root.node
  G = pi.Guesser

  beforeEach ->
    @test_div = Nod.create 'div'
    @test_div.style position:'relative'
    root.append @test_div 

  afterEach ->
    root.empty()
  
  describe "guess components", ->
    it "should guess simple div as base", ->
      nod = Nod.create('<div class="pi" style="position:relative"></div>')
      expect(G.find(nod)).to.eq 'base'

    it "should guess button as button", ->
      nod = Nod.create('<button class="pi" style="position:relative">click</button>')
      expect(G.find(nod)).to.eq 'button'

    it "should guess link as button", ->
      nod = Nod.create('<a class="pi" href="#" style="position:relative">click</a>')
      expect(G.find(nod)).to.eq 'button'

    it "should guess list", ->
      nod = Nod.create('<div class="pi list" href="#" style="position:relative"></div>')
      expect(G.find(nod)).to.eq 'list'

    it "should guess list by tag", ->
      nod = Nod.create '''
        <ul class="pi" href="#" style="position:relative">
        </ul>'''
      expect(G.find(nod)).to.eq 'list'

    it "should guess list by structure", ->
      nod = Nod.create '''
        <div class="pi" href="#" style="position:relative">
          <ul>
          </ul>
        </div>'''
      expect(G.find(nod)).to.eq 'list'

    it "should guess text input by class", ->
      nod = Nod.create '''
        <div class="pi text-input" href="#" style="position:relative">
        </div>'''
      expect(G.find(nod)).to.eq 'text_input'

    it "should guess text input by tag", ->
      nod = Nod.create '''
        <input class="pi" type="text" href="#" style="position:relative"/>
        '''
      expect(G.find(nod)).to.eq 'text_input'

    it "should guess textarea by tag", ->
      nod = Nod.create '''
        <textarea class="pi" type="text" href="#" style="position:relative"/>
        '''
      expect(G.find(nod)).to.eq 'text_area'