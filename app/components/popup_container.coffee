'use strict'
pi = require '../core'
require './pieces'
utils = pi.utils

class pi.PopupContainer extends pi.Base
  postinitialize: ->
    super
    @_popup_id = "p_#{utils.uid()}"
    @__overlays__ = []
    @__containers__ = []
    @__popups__ = []

    @_base_layer =
      if @options.base_layer
        @options.base_layer.split(/\,\s*/).map( (selector) -> pi.Nod.root.find(selector) ).filter( (nod) -> !!nod )
      else
        [ pi.app.view ]

    @z = @options.z || 300
    @show_delay = if @options.show_delay? then @options.show_delay else 200
    @hide_delay = if @options.hide_delay? then @options.hide_delay else 500
    @listen '.pi-overlay', 'click', (e) => @handle_close()

  add_overlay: ->
    @overlay = pi.Nod.create('div').piecify()
    @overlay.addClass 'pi-overlay'
    @overlay.hide()
    @overlay.style("z-index", ++@z)
    @__overlays__.push @overlay
    @append @overlay
    @overlay

  add_container: ->
    @cont = pi.Nod.create('div').piecify()
    @cont.addClass 'pi-popup-container'
    @overlay.style("z-index",++@z)
    @__containers__.push @cont
    @append @cont
    @cont

  # Show target in popup
  # @params [pi.Nod] target
  # @params [Obejct] options 

  open: (@target, options = {}) ->
    @_freeze_layer()

    @overlay.disable() if @overlay?
    @cont.disable() if @cont?

    # create new overlay and container    
    @add_overlay()
    @add_container()

    _target_parent = @target.parent()
    @target.__parent__ = _target_parent
    @target.__popup_options__ = options
    @target.style("z-index", ++@z)
    @target.addClass 'is-popup'
    @target.hide()
    @cont.append @target

    @setup_target @target
    
    @_with_raf('popup_show', => @show())
    
    utils.after @show_delay, =>
      @overlay.show()
      @target.show()
      unless @opened
        @opened = true
        @trigger 'opened', true

    @__popups__.push @target

  setup_target: (target) ->
    options = target.__popup_options__
    
    if options.close is false
      @addClass 'no-close'
    else
      @removeClass 'no-close'

  handle_close: ->
    return unless (options = @target?.__popup_options__)
    
    return if options.close is false

    if typeof options.close is 'function'
      if options.close.call(null) is false
        return
    
    @close() 
    return


  close: ->
    return false if @_closing

    @_closing = true

    @target.hide()
    @overlay.hide()

    # scroll to the top
    pi.Nod.win.scrollY(0)

    if @__overlays__.length is 1
      @opened = false
      @trigger 'opened', false

    new Promise(
      (resolve) =>
        utils.after @hide_delay, =>
          @target.removeClass 'is-popup'
          if @target.__parent__?
            @target.__parent__.append @target
            delete @target.__parent__
            delete @target.__popup_options__
          else
            @target.remove()

          @__popups__.pop()
          @__containers__.pop().remove()
          @__overlays__.pop().remove()
        
          @z -= 3

          if @__overlays__.length
            @cont = @__containers__[@__containers__.length - 1].enable()
            @overlay = @__overlays__[@__overlays__.length - 1].enable()
            @target = @__popups__[@__popups__.length - 1]
            @setup_target @target
          else
            @hide()

          @_unfreeze_layer()

          @_closing = false
          resolve()
        )

  has_content: ->
    @__overlays__.length > 0

  _freeze_layer: ->
    _st = pi.Nod.win.scrollTop()
    
    _elements = 
      if @has_content()
        [@overlay, @cont]
      else
        @_base_layer

    for el in _elements
      unless el.__freezed__
        el.__freezed__ = true
        el.__freezer__ = @_popup_id
        el.__freeze_st__ = _st
        el.style(overflow: 'hidden', top: ''+(el.y() - _st)+'px') 

  _unfreeze_layer: ->
    _st = null

    _elements = 
      if @has_content()
        [@overlay, @cont]
      else
        @_base_layer

    for el in _elements
      do(el) =>
        if el.__freezed__ and el.__freezer__ is @_popup_id
          delete el.__freezed__
          _st = el.__freeze_st__
          el._with_raf('reset_popup_styles', -> el.style(overflow: null, top: null))

    pi.Nod.win.scrollY(_st) if _st?

pi.Guesser.rules_for 'popup_container', ['pi-popup']