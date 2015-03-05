'use strict'
pi = require '../core/pi'

utils = pi.utils

class pi.App
  # Create top-level context (Page)
  # Piecify DOM root
  # Load page
  initialize: (nod) ->
    return false if @_initialized
    @page = new pi.controllers.Page()
    @view = pi.piecify(nod || pi.Nod.root)
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

pi.app = new pi.App()
module.exports = pi.app
