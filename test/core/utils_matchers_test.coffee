'use strict'
TestHelpers = require './helpers'
utils = pi.utils

describe "pieces matchers", ->
  describe "object matcher", ->
    it "should work when match by subkey with unexsistent key", ->
      matcher = utils.matchers.object({data: {item: {id: 1}}})
      expect(matcher({})).to.be.false
      expect(matcher({data: {}})).to.be.false
      expect(matcher({data: {item: {id: 1}}})).to.be.true

    it "should match many keys any", ->
      matcher = utils.matchers.object({data: {item: {id: 1}, flag: true}}, false)
      expect(matcher({})).to.be.false
      expect(matcher({data: {}})).to.be.false
      expect(matcher({data: {item: {id: 1}}})).to.be.true
      expect(matcher({data: {flag: true}})).to.be.true


    it "should match null value", ->
      matcher = utils.matchers.object({data: {item: {parent_id: null}}})
      expect(matcher({})).to.be.false
      expect(matcher({data: {}})).to.be.false
      expect(matcher({data: {item: {parent_id: null}}})).to.be.true
      expect(matcher({data: {item: {}}})).to.be.true