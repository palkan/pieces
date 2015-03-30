'use strict'
h = require 'pieces/test/helpers'
utils = pi.utils

describe "Utils", ->
  describe "Matchers", ->
    it "match by subkey with unexsistent key", ->
      matcher = utils.matchers.object({data: {item: {id: 1}}})
      expect(matcher({})).to.be.false
      expect(matcher({data: {}})).to.be.false
      expect(matcher({data: {item: {id: 1}}})).to.be.true

    it "match many keys any", ->
      matcher = utils.matchers.object({data: {item: {id: 1}, flag: true}}, false)
      expect(matcher({})).to.be.false
      expect(matcher({data: {}})).to.be.false
      expect(matcher({data: {item: {id: 1}}})).to.be.true
      expect(matcher({data: {flag: true}})).to.be.true


    it "match null value", ->
      matcher = utils.matchers.object({data: {item: {parent_id: null}}})
      expect(matcher({})).to.be.false
      expect(matcher({data: {}})).to.be.false
      expect(matcher({data: {item: {parent_id: null}}})).to.be.true
      expect(matcher({data: {item: {}}})).to.be.true