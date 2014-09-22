'use strict'
TestHelpers = require '../helpers'

describe "form component", ->
  Nod = pi.Nod
  root = Nod.create 'div'
  Nod.body.append root.node

  beforeEach ->
    @test_div = Nod.create 'div'
    @test_div.style position:'relative'
    root.append @test_div 

  afterEach ->
    @test_div.remove()

  describe "initialize", ->
    beforeEach ->
      @test_div.append """
        <form class="pi pi-form" data-pid="test">
          <div class="pi pi-text-input-wrap" data-name="desc" data-pid="test" style="position:relative">
            <input type="text" value="1"/>
          </div>
          <input  name="title" type="text" value="Title"/>
          <div class="pi pi-checkbox-wrap" data-name="is_active" style="position:relative">
            <label>CheckBox</label>
            <input type="hidden" value="0"/>
          </div>
          <div class="pi pi-select-field" data-name="type" style="position:relative">
            <input type="hidden" value="2"/>
            <div class="pi placeholder" pid="placeholder" data-placeholder="Не выбрано">Two</div>
            <div class="pi pi-list is-hidden" data-pid="dropdown" style="position:relative">
              <ul class="list">
                <li class="item" data-value="1">One</li>
                <li class="item" data-value="2">Two</li>
                <li class="item" data-value="3">Tre</li>
              </ul>
            </div>
          <button type="submit">Submit</button>
        </form>
      """
      pi.app.view.piecify()
      @example = $('@test')

    it "should be Form", ->
      expect(@example).to.be.an.instanceof pi.Form

    it "should init value", ->
      expect(@example.value().desc).to.eq '1'
      expect(@example.value().is_active).to.eq '0'
      expect(@example.value().type).to.eq '2'
      expect(@example.value().title).to.eq 'Title'

    it "should cache inputs by name", ->
      expect(@example.find_by_name('desc').value()).to.eq '1'
      expect(@example.find_by_name('is_active').value()).to.eq '0'

    it "should find new inputs by name", ->
      @example.append '''<textarea type="text" name="comment">Good news everyone!</textarea>'''
      expect(@example.find_by_name('comment').value()).to.eq 'Good news everyone!'

  describe "inputs update", ->
    beforeEach ->
      @test_div.append """
        <form class="pi" data-pid="test">
          <div id="desc" class="pi pi-text-input-wrap" data-name="desc" data-pid="test" style="position:relative">
            <input type="text" value="1"/>
          </div>
          <input id="title" name="title" type="text" value="Title"/>
          <div id="is_active" class="pi pi-checkbox-wrap" data-name="is_active" style="position:relative">
            <label>CheckBox</label>
            <input type="hidden" value="0"/>
          </div>
          <div id="type" class="pi pi-select-field" data-name="type" style="position:relative">
            <input type="hidden" value="2"/>
            <div class="pi placeholder" pid="placeholder" data-placeholder="Не выбрано">Two</div>
            <div class="pi pi-list is-hidden" data-pid="dropdown" style="position:relative">
              <ul class="list">
                <li class="item" data-value="1">One</li>
                <li class="item" data-value="2">Two</li>
                <li class="item" data-value="3">Tre</li>
              </ul>
            </div>
          <button type="submit">Submit</button>
        </form>
      """
      pi.app.view.piecify()
      @example = $('@test')
    
    it "should handle native inputs updates", (done) ->
      @example.on pi.FormEvent.Update, (e) =>
        expect(@example.value().title).to.eq 'any'
        expect(e.data.title).to.eq 'any'
        done()
      $("#title").value 'any'
      TestHelpers.changeElement $("#title").node

    it "should handle BaseInputs updates", (done) ->
      @example.on pi.FormEvent.Update, (e) =>
        expect(@example.value().desc).to.eq 'long description'
        expect(e.data.desc).to.eq 'long description'
        done()

      $("#desc input").value 'long description'
      TestHelpers.changeElement $("#desc input").node

    it "should set inputs values", ->
      @example.value desc: 'Song', title: 'EA', is_active: true, type: 3, bull: 'shit' 
      
      expect($("#desc").value()).to.eq 'Song'
      expect($("#title").value()).to.eq 'EA'
      expect($("#is_active").value()).to.eq '1'
      expect($("#type").value()).to.eq '3'
      expect($("#type").placeholder.text()).to.eq 'Tre'

      val = @example.value()
      expect(val.desc).to.eq 'Song'
      expect(val.title).to.eq 'EA'
      expect(val.is_active).to.eq '1'
      expect(val.type).to.eq '3'
      expect(val).to.have.keys ['desc', 'title', 'is_active', 'type']

    it "should clear inputs values", ->
      @example.clear()
      
      expect($("#desc").value()).to.eq ''
      expect($("#title").value()).to.eq ''
      expect($("#is_active").value()).to.eq '0'
      expect($("#type").value()).to.eq ''
      expect($("#type").placeholder.text()).to.eq 'Не выбрано'

  describe "rails names", ->
    beforeEach ->
      @test_div.append """
        <form class="pi" data-pid="test" data-rails="true">
          <div id="fullname" class="pi pi-text-input-wrap" data-name="user[fullname]" data-pid="test" style="position:relative">
            <input type="text" value="John Green"/>
          </div>
          <div id="desc" class="pi pi-text-input-wrap" data-name="user[post][desc]" data-pid="test" style="position:relative">
            <input type="text" value="1"/>
          </div>
          <input id="title" name="user[post][title]" type="text" value="Title"/>
          <div id="is_active" class="pi pi-checkbox-wrap" data-name="user[post][is_active]" style="position:relative">
            <label>CheckBox</label>
            <input type="hidden" value="0"/>
          </div>
          <div id="type" class="pi pi-select-field" data-name="user[post][type]" style="position:relative">
            <input type="hidden" value="2"/>
            <div class="pi placeholder" pid="placeholder" data-placeholder="Не выбрано">Two</div>
            <div class="pi pi-list is-hidden" data-pid="dropdown" style="position:relative">
              <ul class="list">
                <li class="item" data-value="1">One</li>
                <li class="item" data-value="2">Two</li>
                <li class="item" data-value="3">Tre</li>
              </ul>
            </div>
          <ul>
            <li>
              <input type="hidden" name="options[][id]" value="1"/>
              <input type="hidden" name="options[][key]" value="a"/>
            </li>
            <li> 
              <input type="hidden" name="options[][id]" value="2"/>
              <input type="hidden" name="options[][key]" value="b"/>
            </li>
          </ul>
          <button type="submit">Submit</button>
        </form>
      """
      pi.app.view.piecify()
      @example = $('@test')
    
    it "should init values", ->
      expect(@example.value().user.fullname).to.eq 'John Green'
      expect(@example.value().user.post.is_active).to.eq '0'
      expect(@example.value().user.post.type).to.eq '2'
      expect(@example.value().user.post.title).to.eq 'Title'
      expect(@example.value().user.post.desc).to.eq '1'
      expect(@example.value().options).to.have.length 2
      expect(@example.value().options[0].key).to.eq 'a'
      expect(@example.value().options[1].key).to.eq 'b'

    it "should set inputs values", ->
      @example.value user: {fullname: 'Ivan', post: {desc: 'Song', title: 'EA', is_active: true, type: 3}}
      
      expect($("#fullname").value()).to.eq 'Ivan'
      expect($("#desc").value()).to.eq 'Song'
      expect($("#title").value()).to.eq 'EA'
      expect($("#is_active").value()).to.eq '1'
      expect($("#type").value()).to.eq '3'
      expect($("#type").placeholder.text()).to.eq 'Tre'


    it "should clear inputs values", ->
      @example.clear()
      expect($("#fullname").value()).to.eq ''
      expect($("#desc").value()).to.eq ''
      expect($("#title").value()).to.eq ''
      expect($("#is_active").value()).to.eq '0'
      expect($("#type").value()).to.eq ''
      expect($("#type").placeholder.text()).to.eq 'Не выбрано'


  describe "submit", ->
    beforeEach ->
      @test_div.append """
        <form class="pi" data-pid="test" data-rails="true">
          <div id="fullname" class="pi pi-text-input-wrap" data-name="user[fullname]" data-pid="test" style="position:relative">
            <input type="text" value="John Green"/>
          </div>
          <div id="desc" class="pi pi-text-input-wrap" data-name="user[post][desc]" data-pid="test" style="position:relative">
            <input type="text" value="1"/>
          </div>
          <input id="title" name="user[post][title]" type="text" value="Title"/>
          <div id="is_active" class="pi pi-checkbox-wrap" data-name="user[post][is_active]" style="position:relative">
            <label>CheckBox</label>
            <input type="hidden" value="0"/>
          </div>
          <div id="type" class="pi pi-select-field" data-name="user[post][type]" style="position:relative">
            <input type="hidden" value="2"/>
            <div class="pi placeholder" pid="placeholder" data-placeholder="Не выбрано">Two</div>
            <div class="pi pi-list is-hidden" data-pid="dropdown" style="position:relative">
              <ul class="list">
                <li class="item" data-value="1">One</li>
                <li class="item" data-value="2">Two</li>
                <li class="item" data-value="3">Tre</li>
              </ul>
            </div>
          <button type="submit">Submit</button>
        </form>
      """
      pi.app.view.piecify()
      @example = $('@test')
    
    it "should send submit event on native submit", (done) ->
      @example.on pi.FormEvent.Submit, (e) =>
        expect(e.data.user.fullname).to.eq 'John Green'
        done()

      TestHelpers.submitElement @example.form.node


    it "should send submit on own submit", (done) ->
      @example.on pi.FormEvent.Submit, (e) =>
        expect(e.data.user.fullname).to.eq 'John Green'
        done()

      @example.submit()


  describe "validations", ->
    beforeEach ->
      @test_div.append """
        <form class="pi" data-pid="test" data-rails="true">
          <div id="fullname" class="pi pi-text-input-wrap" data-validates="presence" data-name="user[fullname]" style="position:relative">
            <input type="text" value=""/>
          </div>
          <div id="email" class="pi pi-text-input-wrap" data-validates="email" data-name="user[email]" style="position:relative">
            <input type="email" value=""/>
          </div>
          <div id="phone" class="pi pi-text-input-wrap" data-validates="digital len(8)" data-name="user[phone]" style="position:relative">
            <input type="telephone" value=""/>
          </div>
          <input id="pass" name="user[password]" data-validates="len(6) confirm" type="password" value=""/>
          <input id="pass_confirm" name="user[password_confirmation]" type="password" value=""/>
          <div id="offer" data-validates="truth" class="pi pi-checkbox-wrap" data-name="offer" style="position:relative">
            <label>CheckBox</label>
            <input type="hidden" value="1"/>
          </div>
          <div id="type" class="pi pi-select-field" data-validates="custom(2)" data-name="type" style="position:relative">
            <input type="hidden" value=""/>
            <div class="pi placeholder" pid="placeholder" data-placeholder="Не выбрано"></div>
            <div class="pi pi-list is-hidden" data-pid="dropdown" style="position:relative">
              <ul class="list">
                <li class="item" data-value="1">One</li>
                <li class="item" data-value="2">Two</li>
                <li class="item" data-value="3">Tre</li>
              </ul>
            </div>
          <button type="submit">Submit</button>
        </form>
      """
      
      pi.BaseInput.Validator.add "custom", (val, nod, form, data) ->
        (val|0) is data

      pi.app.view.piecify()
      @example = $('@test')
    
    it "should validate initial state on submit", ->
      @example.validate()

      expect($("#fullname").hasClass('is-invalid')).to.be.true
      expect(@example._invalids).to.include 'user[fullname]'
      
      expect($("#email").hasClass('is-invalid')).to.be.true
      expect(@example._invalids).to.include 'user[email]'

      expect($("#phone").hasClass('is-invalid')).to.be.true
      expect(@example._invalids).to.include 'user[phone]'

      expect($("#type").hasClass('is-invalid')).to.be.true
      expect(@example._invalids).to.include 'type'

    it "should handle presence validation", ->
      TestHelpers.changeElement $("#fullname input").node

      expect($("#fullname").hasClass('is-invalid')).to.be.true
      expect(@example._invalids).to.include 'user[fullname]'

      $("#fullname input").value 'jo hahn'

      TestHelpers.changeElement $("#fullname input").node

      expect($("#fullname").hasClass('is-invalid')).to.be.false
      expect(@example._invalids).to.have.length 0

    it "should handle email validation", ->
      TestHelpers.changeElement $("#email input").node

      expect($("#email").hasClass('is-invalid')).to.be.true
      expect(@example._invalids).to.include 'user[email]'

      $("#email input").value 'jo.hash@gmail.com'

      TestHelpers.changeElement $("#email input").node

      expect($("#email").hasClass('is-invalid')).to.be.false      
      expect(@example._invalids).to.have.length 0

    it "should handle digital and length validation", ->
      $("#phone input").value '9284'
      TestHelpers.changeElement $("#phone input").node

      expect($("#phone").hasClass('is-invalid')).to.be.true
      expect(@example._invalids).to.include 'user[phone]'

      $("#phone input").value '92rrwtwet84'
      TestHelpers.changeElement $("#phone input").node

      expect($("#phone").hasClass('is-invalid')).to.be.true
      expect(@example._invalids).to.include 'user[phone]'

      $("#phone input").value '8(123)4567890'

      TestHelpers.changeElement $("#phone input").node

      expect($("#phone").hasClass('is-invalid')).to.be.false      
      expect(@example._invalids).to.have.length 0

    it "should handle confirm validation", ->
      TestHelpers.changeElement $("#pass").node

      expect($("#pass").hasClass('is-invalid')).to.be.true
      expect(@example._invalids).to.include 'user[password]'

      $("#pass").value 'qwerty'
      TestHelpers.changeElement $("#pass").node

      expect($("#pass").hasClass('is-invalid')).to.be.true
      expect(@example._invalids).to.include 'user[password]'

      $("#pass_confirm").value 'qwerty'

      TestHelpers.changeElement $("#pass").node

      expect($("#pass").hasClass('is-invalid')).to.be.false      
      expect(@example._invalids).to.have.length 0

    it "should handle custom validation", ->
      TestHelpers.clickElement $("#type .item").node

      expect($("#type").hasClass('is-invalid')).to.be.true
      expect(@example._invalids).to.include 'type'

      TestHelpers.clickElement $("#type").nth(".item",2).node
   
      expect($("#type").hasClass('is-invalid')).to.be.false      
      expect(@example._invalids).to.have.length 0

    it "should handle truth validation", ->

      TestHelpers.clickElement $("#offer").node

      expect($("#offer").hasClass('is-invalid')).to.be.true
      expect(@example._invalids).to.include 'offer'

      TestHelpers.clickElement $("#offer").node
       
      expect($("#offer").hasClass('is-invalid')).to.be.false      
      expect(@example._invalids).to.have.length 0



