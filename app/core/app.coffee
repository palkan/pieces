'use strict'
Nod = require('./nod').Nod
Page = require '../controllers/page'
utils = require './utils'

class App
  # Create top-level context (Page)
  # Load page
  initialize: (nod) ->
    return false if @_initialized
    @page = new Page()
    @view = (nod ? Nod.root).piecify()
    @_initialized = true
    @page.load()

  # Re-piecify DOM root
  # Dispose and load page
  reinitialize: ->
    return false unless @_initialized
    @page.dispose()
    @view.piecify()
    @page.load()

  # Dispose page
  # Remove view children
  dispose: ->
    return false unless @_initialized
    @page.dispose()
    @view.remove_children()
    true

module.exports = App
