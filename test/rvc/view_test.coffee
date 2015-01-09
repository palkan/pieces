'use strict'
h = require './helpers'

describe "pi calls with view", ->
  root = h.test_cont(pi.Nod.body)

  after ->
    root.remove()

  test_div = example = null

  beforeEach ->
    test_div = h.test_cont root, '''
      <div><div class="pi test" data-pid="test" data-component="base_view">
        <span pid="btn" class="pi" data-on-click="@view.log.text('bla')"></span>
        <span pid="log" class="pi">loggo</span>
      </div></div>
      '''
    pi.app.view.piecify()
    example = test_div.find('.test')

  it "should work with view call", ->
    h.clickElement example.btn.node
    expect(example.log.text()).to.eq 'bla'