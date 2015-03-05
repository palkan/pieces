'use strict'
h = require 'pi/test/helpers'

describe "Component Initializer", ->
  Nod = pi.Nod
  it "parse options", ->
    el = Nod.create('<div data-component="test" data-hidden="true" data-collection-id="13" data-plugins="autoload search filter"></div>')
    options = pi.ComponentInitializer.gather_options el
    expect(options).to.include({component:"test",hidden:true,collection_id:13}).and.to.have.property('plugins').with.length(3)

  it "init base component", ->
    el = Nod.create('<div data-component="test_component" data-hidden="true"></div>')
    component = pi.ComponentInitializer.init el
    expect(component).to.be.an.instanceof pi.TestComponent
    expect(component.visible).to.be.false

  it "return undefined if component not found", ->
    el = Nod.create('<div data-component="testtt" data-hidden="true"></div>')
    expect(pi.ComponentInitializer.init(el)).to.be.undefined

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
    el = pi.ComponentInitializer.init el
    el.html _html
    expect(el.find_cut('.pi')).to.have.length 3
