'use strict'
h = require 'pieces-core/test/helpers'

describe "Component Initializer", ->
  Nod = pi.Nod
  it "parse options", ->
    el = Nod.create('<div data-component="test" data-hidden="true" data-collection-id="13" data-plugins="autoload search filter"></div>')
    options = pi.Initializer.gather_options el
    expect(options).to.include({component:"test",hidden:true,collection_id:13}).and.to.have.property('plugins').with.length(3)

  it "init base component", ->
    el = Nod.create('<div data-component="test_component" data-hidden="true"></div>')
    component = pi.Initializer.init el
    expect(component).to.be.an.instanceof $c.TestComponent
    expect(component.visible).to.be.false

  it "return undefined if component not found", ->
    el = Nod.create('<div data-component="testtt" data-hidden="true"></div>')
    expect(pi.Initializer.init(el)).to.be.undefined

  it "find cut", ->
    _html = '''
    <h1 class="title">File input</h1>
    <div class="content">
      <div class="inline">
        <div pid="btn" data-on-files_selected="@host.list.data_provider(e.data)" class="pi button-blue file-input-wrap">choose file
          <input type="file" class="file-input">
        </div>
        <div data-on-selected="@host.btn.multiple(e.data)" class="pi checkbox-wrap">
          <label class="cb-label">Multiple?</label>
          <input type="hidden">
        </div>
      </div>
      <div pid="list" data-renderer="mustache(file_item_mst)" class="pi inline list-container">
        <ul class="list"></ul>
      </div>
    </div>
    '''
    el = Nod.create('div')
    el = pi.Initializer.init el
    el.html _html
    expect(el.find_cut('.pi')).to.have.length 3
