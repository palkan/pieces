'use strict'
h = require 'pi/test/helpers'

describe "Net utils base", ->
  net = pi.net
  utils = pi.utils

  describe "xhr net utils", ->
    it "should prepare params", ->
      data = 
        item:
          tags: ['1','2']
          id: 1
          owner:
            name: 'john'
            age: 10
      params = net._to_params(data).map( (p) -> p.name)
      expect(params).to.have.length 5
      expect(params).to.include 'item[tags][]'
      expect(params).to.include 'item[id]'
      expect(params).to.include 'item[owner][name]'
      expect(params).to.include 'item[owner][age]'

    it "should prepare params with Date and File/Blob", ->
      d = new Date()
      data = 
        item:
          tags: ['1','2']
          id: 1
          started_at: d
          file: new Blob(['<div class="blob"></div>'],type : 'text/html')
      
      data = net._to_params(data)
      params = data.map( (p) -> p.name)
      
      expect(params).to.have.length 5
      expect(params).to.include 'item[tags][]'
      expect(params).to.include 'item[id]'
      expect(params).to.include 'item[started_at]'
      expect(params).to.include 'item[file]'
      
      started_at = data.filter( (p) -> p.name is 'item[started_at]')[0].value
      expect(started_at).to.eq d.getTime()

      file = data.filter( (p) -> p.name is 'item[file]')[0].value
      expect(file).to.be.instanceof Blob

    it "should create query from data", ->
      data = id:1, name:'Ivan Fuckov'
      expect(net._data_to_query(data)).to.eq 'id=1&name=Ivan%20Fuckov' 

  describe "requests", ->
    it "should send get request without data", (done) ->
      net.get('/echo?q=1').then( (data) ->
        expect(data.q).to.eq '1'
        done()
      ).catch(done)

    it "should send get request with data", (done) ->
      net.get('/echo',{q:1}).then( (data) ->
        expect(data.q).to.eq '1'
        done()
      ).catch(done)

    it "should send get request with data and url query", (done) ->
      net.get('/echo?a=test',{q:1}).then( (data) ->
        expect(data.q).to.eq '1'
        expect(data.a).to.eq 'test'
        done()
      ).catch(done)

    it "should send get request with nested data", (done) ->
      net.get('/echo',{item:{id:1,user:{id:123,name:'john'}}}).then( (data) ->
        expect(data.item.id).to.eq '1'
        expect(data.item.user.name).to.eq 'john'
        done()
      ).catch(done)

    it "should send post request with data", (done) ->
      net.post('/echo',{item:{id:1,user:{id:123,name:'john'}}},{json: false}).then( (data) ->
        expect(data.post.item.id).to.eq '1'
        expect(data.post.item.user.name).to.eq 'john'
        done()
      ).catch(done)

    # PATCH and DELETE doesn't work in PhantomJs! https://github.com/ariya/phantomjs/issues/11384
    unless window.mochaPhantomJS
      it "should send patch request with data", (done) ->
        net.patch('/echo',{item:{id:1,user:{id:123,name:'john'}}},{json: false}).then( (data) ->
          expect(data.patch.item.id).to.eq '1'
          expect(data.patch.item.user.name).to.eq 'john'
          done()
        ).catch(done)

      it "should send delete request with data", (done) ->
        net.delete('/echo',{item:{id:1,user:{id:123,name:'john'}}},{json: false}).then( (data) ->
          expect(data.delete.item.id).to.eq '1'
          expect(data.delete.item.user.name).to.eq 'john'
          done()
        ).catch(done)

    it "should send post request with data as json", (done) ->
      net.post('/echo',{item:{id:1,user:{id:123,name:'john'}}}).then( (data) ->
        expect(data.post.item.id).to.eq 1
        expect(data.post.item.user.name).to.eq 'john'
        done()
      ).catch(done)



  describe "iframe upload utils", ->
    it "should create form", ->
      data = 
        item:
          tags: ['1','2']
          owner:
            name: 'john'
            age: 10
          
      data = net._to_params(data)
      form = pi.Nod.create """
          <form>
            <input type="text" name="item[id]" value="1"/>
          </form>
        """  
      form = net.IframeUpload._build_form form, '#', data, '', 'post'
      f = new pi.Former(form.node, serialize: true, rails: true)
      form_data = f.collect_name_values()
      params = form_data.map((f)-> f.name)
      expect(params).to.include 'item[tags][]'
      expect(params).to.include 'item[id]'
      expect(params).to.include 'item[owner][name]'
      expect(params).to.include 'item[owner][age]'

  describe "iframe upload (data only)", ->

    beforeEach ->
      @form = pi.Nod.create """
          <form>
            <input type="text" name="item[id]" value="1"/>
          </form>
        """  
      pi.Nod.body.append @form

    afterEach ->
      @form.remove()

    it "shuld upload data", (done) ->
      net.iframe_upload(@form, '/upload',{item:{user:{id:123,name:'john'}}}).then(
        ((data) ->
          expect(data.data.item.id).to.eq '1'
          expect(data.data.item.user.name).to.eq 'john'
          done()),
        (e) -> pi.utils.error(e)
      )