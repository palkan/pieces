'use strict'
pi = require '../core'
require './pieces'
utils = pi.utils

class pi.PopupContainer extends pi.Base
  postinitialize: ->
    super
    @__overlays__ = []
    @__containers__ = []
    @__popups__ = []
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
    # disable previous popup if any
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
    
    @show()
    
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

          @_closing = false
          resolve()
        )

pi.Guesser.rules_for 'popup_container', ['pi-popup']