'use strict'
h = require 'pieces-core/test/helpers'
utils = pi.utils

describe "Utils", ->
  describe "Functions", ->
    dummy = ->
      obj=
        request: (ts, data) ->
          new Promise((resolve) -> utils.delayed(ts, resolve, [data]).call())
        log_data: ''
        handler: ->
          _uid = utils.uid('handler')
          (e) ->
            return id: _uid, event: e  

    it "wrap promised function", (done) ->
      obj = dummy()

      _before = ->
        ts: new Date()
      _after = (res, _, start) ->
        res.then( =>
          @log_data = new Date() - start.ts
        )

      obj.request = utils.func.wrap(obj.request, _before, _after)
      obj.request(100, 101).then(
        (res) ->
          expect(res).to.eq 101
          expect(obj.log_data).to.be.below(120).and.above(80) 
          done()
      ).catch(done)

    it "wrap event handler", ->
      obj = dummy()

      _before = ->
        if obj.__handler__
          return obj.__handler__

      _after = (res) ->
        obj.__handler__ = res

      obj.handler = utils.func.wrap(obj.handler, _before, _after, break_if_value: true)
      expect(obj.handler()(2).id).to.eq obj.handler()(4).id


    it "prepend simple function", ->
      _pass = (num) -> num
      _even = (num) -> (num % 2) is 0

      _pass_even = utils.func.prepend(_pass, (num) -> utils.func.BREAK unless _even(num))
      _pass_even_with_false = utils.func.prepend(_pass, ((num) -> utils.func.BREAK unless _even(num)), break_with: false)

      expect(_pass_even(1)).to.be.undefined
      expect(_pass_even_with_false(1)).to.be.false
      expect(_pass_even(4)).to.eq 4

    it "append simple function", ->
      _even = (num) -> num % 2

      _log_str = ''        
      
      _log = (res, args) -> 
        if res
          _log_str = "#{args[0]} is odd"
        else
          _log_str = "#{args[0]} is even"
      
      _log_even = utils.func.append(_even, _log)

      _log_even(1)
      expect(_log_str).to.eq "1 is odd"
      _log_even(2)
      expect(_log_str).to.eq "2 is even"
      