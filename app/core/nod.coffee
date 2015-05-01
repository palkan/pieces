'use strict'
utils = require './utils'
EventDispatcher = require('./events').EventDispatcher
Event = require('./events').Event

# Exports NodEventDispatcher, Nod, NodEvent, MouseEvent, KeyEvent
exports = {}

# General wrapper for native events.
# 
# **Aliases**
# 
# Event aliases can be used to handle browser differences (e.g. 'mousewheel' and 'DOMMouseScroll') 
# or in any other case when you want to substitute event type with another one.
# 
# Example:
#   // Create mobile aliases
#   NodEvent.register_alias('mousemove', 'touchmove')
# 
# **Delegates**
# 
# Delegates can be used to create custom events, such as 'resize'.
# @see ResizeDelegate.
class NodEvent extends Event

  @aliases: {}
  @reversed_aliases: {}
  @delegates: {}

  @add: (nod, event, handler) ->
    nod.addEventListener(event, handler)

  @remove: (nod, event, handler) ->  
    nod.removeEventListener(event, handler)

  @register_delegate: (type, delegate) ->
    @delegates[type] = delegate

  @has_delegate: (type) ->
    !!@delegates[type]

  @register_alias: (from, to) ->
    @aliases[from] = to
    @reversed_aliases[to] = from

  @has_alias: (type) ->
    !!@aliases[type]

  @is_aliased: (type) ->
    !!@reversed_aliases[type]

  constructor: (event) ->
    @event = event || window.event  

    @origTarget = @event.target || @event.srcElement
    @target = Nod.create @origTarget
    @type = if @constructor.is_aliased(event.type) then @constructor.reversed_aliases[event.type] else event.type
    @ctrlKey = @event.ctrlKey
    @shiftKey = @event.shiftKey
    @altKey = @event.altKey
    @metaKey = @event.metaKey
    @detail = @event.detail
    @bubbles = @event.bubbles

  stopPropagation: ->
    if @event.stopPropagation 
      @event.stopPropagation()
    else
      @event.cancelBubble = true

  stopImmediatePropagation: ->
    if @event.stopImmediatePropagation 
      @event.stopImmediatePropagation()
    else
      @event.cancelBubble = true
      @event.cancel = true

  preventDefault: ->
    if @event.preventDefault
      @event.preventDefault()
    else
      @event.returnValue = false

  cancel: ->
    @stopImmediatePropagation()
    @preventDefault()
    super

exports.NodEvent = NodEvent

_mouse_regexp = /(click|mouse|contextmenu)/i

_key_regexp = /(keyup|keydown|keypress)/i

class MouseEvent extends NodEvent
  constructor: ->
    super
    
    @button = @event.button

    unless @pageX?
      @pageX = @event.clientX + document.body.scrollLeft + document.documentElement.scrollLeft 
      @pageY = @event.clientY + document.body.scrollTop + document.documentElement.scrollTop

    unless @offsetX?
      @offsetX = @event.layerX - @origTarget.offsetLeft
      @offsetY = @event.layerY - @origTarget.offsetTop

    @wheelDelta = @event.wheelDelta
    unless @wheelDelta?
      @wheelDelta = -@event.detail*40

exports.MouseEvent = MouseEvent

class KeyEvent extends NodEvent
  constructor: ->
    super      
    @keyCode = @event.keyCode || @event.which
    @charCode = @event.charCode


exports.KeyEvent = KeyEvent
  
_prepare_event = (e) ->
  if _mouse_regexp.test e.type
    new MouseEvent e
  else if _key_regexp.test e.type
    new KeyEvent e
  else
    new NodEvent e

_selector_regexp = /^[\.#]/

_selector = (s, parent) ->
  # when selector is tag (for links default behaviour preventing)
  unless _selector_regexp.test s
    (e) ->
      return e.target.node.matches(s)
  else
    (e) ->
      parent ||= document
      node = e.target.node
      return true if node.matches(s) 
      return false if node is parent
      while((node = node.parentNode) and node != parent)
        return (e.target = Nod.create(node)) if node.matches(s)


# NodEventDispatcher extends EventDispatcher by adding/removing native listeners
class NodEventDispatcher extends EventDispatcher
  constructor: ->
    super
    @native_event_listener = (event) => 
      @trigger _prepare_event(event)  

  listen: (selector, event, callback, context) ->
    @on event, callback, context, _selector(selector, @node)

  add_native_listener: (type) ->
    if NodEvent.has_delegate type
      NodEvent.delegates[type].add @, @native_event_listener
    else 
      NodEvent.add @node, type, @native_event_listener 

  remove_native_listener: (type) ->
    if NodEvent.has_delegate type
      NodEvent.delegates[type].remove @
    else
      NodEvent.remove @node, type, @native_event_listener


  add_listener: (listener) ->
    if !@listeners[listener.type]
      if NodEvent.has_alias(listener.type)
        @add_native_listener NodEvent.aliases[listener.type] 
      else
        @add_native_listener listener.type
    super

  remove_type: (type) ->
    if NodEvent.has_alias(type)
      @remove_native_listener NodEvent.aliases[type] 
    else
      @remove_native_listener type  
    super

  remove_all: ->
    for own type,list of @listeners
      do =>
        if NodEvent.has_alias(type)
          @remove_native_listener NodEvent.aliases[type]
        else
          @remove_native_listener type
    super

exports.NodEventDispatcher = NodEventDispatcher


_prop_hash = (method, callback) ->
  Nod::[method] = (prop, val) ->
    unless typeof prop is "object" 
      return callback.call @, prop, val
    for own k,p of prop
      callback.call @, k, p
    return

_geometry_styles = (sty) ->
  for s in sty
    do ->
      name = s
      Nod::[name] = (val) ->
        if val is undefined 
          return @node["offset#{utils.capitalize(name)}"]
        @_with_raf name, => 
          @node.style[name] = val+"px"
          @trigger('resize') if name is 'width' or name is 'height'
        @
      return
  return

_settegetter = (prop) ->
  if Array.isArray(prop)
    name = prop[0]
    prop = prop[1]
  else
    name = prop
  Nod::[name] = (val) ->
    if val?
      @node[prop] = val
      @
    else
      @node[prop]

# generate document fragment from html string
_fragment = (html) ->
  temp = document.createElement 'div'
  temp.innerHTML = html
  f = document.createDocumentFragment()
  while(temp.firstChild)
    f.appendChild temp.firstChild 
  f

_node = (n) ->
  if n instanceof Nod
    return n.node
  if typeof n is "string"
    return _fragment n
  n

_data_reg = /^data-\w[\w\-]*$/

# data case is: 'word1-word2-word3'
# returns snake_case: 'word1_word2_word3'
_from_dataCase = (str) ->
  words = str.split '-'
  words.join('_')

# 'dataset' is not supported in <IE11
_dataset = 
  (-> 
    if typeof DOMStringMap is "undefined" 
      (node) ->  
        dataset = {}

        # old ie window doesn't have attributes
        if node.attributes?
          for attr in node.attributes
            if _data_reg.test(attr.name)
              dataset[_from_dataCase(attr.name[5..])] = utils.serialize attr.value
        return dataset
    else
      (node) ->
        dataset = {}
        for own key,val of node.dataset
          dataset[utils.snake_case(key)] = utils.serialize val
        dataset
  )()

_raf = 
  if window.requestAnimationFrame?
    window.requestAnimationFrame
  else
    (callback) ->
      utils.after 0, callback

_caf =
  if window.cancelAnimationFrame?
    window.cancelAnimationFrame
  else
    utils.pass

# used to store references to nodes and components
_store = {}

# DOMElement wrapper
class Nod extends NodEventDispatcher
  # Add _nod attribute to node with uniq
  # Nod id and store reference
  @store: (nod, overwrite = false) ->
    node = nod.node
    return if node._nod && _store[node._nod] && !overwrite
    node._nod = utils.uid("nod")
    _store[node._nod] = nod

  # Fetch Nod by id
  @fetch: (id) ->
    id && _store[id]

  @delete: (nod) ->
    delete _store[nod.node?._nod]

  # create new Nod from HTMLElement, HTML string, tag name or even another Nod (just returns it)
  @create: (node) ->
    switch 
      when !node then null
      when node instanceof @ then node
      when (typeof node["_nod"] isnt "undefined") then Nod.fetch(node._nod)
      when utils.is_html(node) then @_create_html(node)
      when typeof node is "string" then new @(document.createElement node)
      else new @(node)

  @_create_html: (html) ->
    temp = _fragment html
    node = temp.firstChild
    temp.removeChild node
    new @(node)

  constructor: (@node) ->
    super
    throw Error("Node is undefined!") unless @node?

    @_disposed = false

    # virtual data element
    @_data = _dataset(@node)

    Nod.store(@)

  # return first matching element as Nod
  find: (selector) ->
    Nod.create @node.querySelector(selector)

  # return all matching Elements without modifying 
  all: (selector) ->
    @node.querySelectorAll selector


  # invoke callback on each matching Element (not Nod!)
  each: (selector, callback) ->
    i=0
    for node in @node.querySelectorAll selector
      break if callback.call(null, node, i) is true
      i++

  first: (selector) ->
    @find selector

  last: (selector) ->
    @find "#{selector}:last-child"

  nth: (selector, n) ->
    @find "#{selector}:nth-child(#{n})"

  # breadth-first selector find
  find_bf: (selector) ->
    rest = []
    acc = []

    el = @node.firstChild
      
    while(el)
      if el.nodeType != 1
        el = el.nextSibling || rest.shift()
        continue
      
      if el.matches(selector)
        acc.push el
        nod = el.querySelector selector
        if nod?
          rest.push nod
      else        
        if (nod = el.querySelector(selector))
          el.nextSibling && rest.unshift(el.nextSibling)
          el = nod
          continue
      el = el.nextSibling || rest.shift()        
  
    acc

  find_cut: (selector) ->
    rest = []
    acc = []

    el = @node.firstChild

    while(el)
      if el.nodeType != 1
        el = el.nextSibling || rest.shift()
        continue
      if el.matches(selector)
        acc.push el
      else        
        el.firstChild && rest.unshift(el.firstChild)
      el = el.nextSibling || rest.shift()        
    acc

  # set multiple attributes
  attrs: (data) ->
    for own name,val of data        
      @attr name, val
    @

  # set multiple styles
  styles: (data) ->
    for own name,val of data        
      @style name, val
    @

  # return parent Element as Nod
  parent: (selector) ->
    unless selector?
      if @node.parentNode?
        Nod.create(@node.parentNode) 
      else
        null
    else
      p = @node
      while((p = p.parentNode) && (p != document))
        if p.matches(selector)
          return Nod.create p
      return null

  # return children Elements without modifying 
  children: (selector) ->
    if selector?
      n for n in @node.children when n.matches(selector)
    else
      @node.children

  # wrap node in a DIV with klasses
  wrap: (klasses...) ->
    wrapper = Nod.create 'div'
    wrapper.addClass.apply wrapper, klasses

    @node.parentNode.insertBefore wrapper.node, @node
    wrapper.append @node

  # prepend node children with HTMLElement or HTML string
  prepend: (node) -> 
    node = _node node
    @node.insertBefore node, @node.firstChild
    @

  # append HTMLElement or HTML string to node children
  append: (node) ->
    node = _node node
    @node.appendChild node
    @

  insertBefore: (node) ->
    node = _node node
    @node.parentNode.insertBefore node, @node
    @

  insertAfter: (node) ->
    node = _node node
    @node.parentNode.insertBefore node, @node.nextSibling
    @

  # remove node from parent node
  detach: ->
    @node.parentNode?.removeChild @node
    @

  # detach all node children
  detach_children: ->
    while @node.children.length
      @node.removeChild @node.children[0]
    @

  remove_children: ->
    while(@node.firstChild)
      if (nod = Nod.fetch(@node.firstChild._nod))
        nod.remove()
      else
        @node.removeChild @node.firstChild
    @

  @alias 'empty', 'remove_children'

  # detach and dispose
  # return null
  remove: ->
    @detach()
    @remove_children()
    @dispose()
    null

  clone: ->
    c = document.createElement @node.nameNode
    c.innerHTML = @node.outerHTML
    nod = new Nod(c.firstChild)
    utils.extend nod, @, true, ['listeners', 'listeners_by_type', '__components__', 'native_event_listener', 'node']

  # remove event listeners and internal links
  dispose: ->
    return if @_disposed
    @off()
    Nod.delete(@)
    @_disposed = true
    return

  name: ->
    @node.name || @data('name')

  addClass: () ->
    @node.classList.add(c) for c in arguments
    @

  removeClass: () ->
    @node.classList.remove(c) for c in arguments
    @

  toggleClass: (c) ->
    @node.classList.toggle c
    @

  hasClass: (c) ->
    @node.classList.contains c

  mergeClasses: (nod) ->
    for klass in nod.node.className.split(/\s+/)
      @addClass(klass) if klass
    @
    
  x: ->
    offset = @node.offsetLeft
    node = @node
    while (node = node.offsetParent)
      offset += node.offsetLeft
    offset

  y: ->
    offset = @node.offsetTop
    node = @node
    while (node = node.offsetParent) 
      offset += node.offsetTop
    offset

  _with_raf: (name, fun) ->
    if @["__#{name}_rid"]
      _caf(@["__#{name}_rid"])
      delete @["__#{name}_rid"]

    @["__#{name}_rid"] = _raf(fun)

  move: (x,y) ->
    @_with_raf 'move', => @style(left: "#{x}px", top: "#{y}px")

  moveX: (x) ->
    @left x

  moveY: (y) ->
    @top y

  scrollX: (x) ->
    @_with_raf 'scrollX', => @node.scrollLeft = x

  scrollY: (y) ->
    @_with_raf 'scrollY', => @node.scrollTop = y

  position: () ->
    x: @x(), y: @y() 

  offset: () ->
    x: @node.offsetLeft, y: @node.offsetTop 

  size: (width = null, height = null) ->
    unless width? and height?
      return width: @width(), height: @height()
    
    unless width?
      width = @width()

    unless height?
      height = @height()

    @_with_raf 'size', =>
      @node.style.width = width+"px"
      @node.style.height = height+"px"
      @trigger 'resize'
    return

  show: ->
    @node.style.display = "block"

  hide: ->
    @node.style.display = "none"

  focus: ->
    @node.focus()
    @

  blur: ->
    @node.blur()
    @

_prop_hash(
  "data", 
  (prop, val) ->
    return @_data if prop is undefined
    
    prop = prop.replace("-","_")

    if val is null
      val = @_data[prop]
      delete @_data[prop]
      return val
    if val is undefined 
      @_data[prop]
    else
      @_data[prop] = val
      @
)

_prop_hash(
  "style", 
  (prop, val) -> 
    if val is null
      @node.style.removeProperty(prop)
    else if val is undefined 
      return @node.style[prop]
    @node.style[prop] = val
)

_prop_hash(
  "attr", 
  (prop, val) ->
    if val is null 
      @node.removeAttribute prop
    else if val is undefined 
      @node.getAttribute prop
    else
      @node.setAttribute prop, val
)

_geometry_styles ["top", "left", "width", "height"]


for prop in [['html','innerHTML'], 'outerHTML', ['text','textContent'], 'value']
  do ->
    _settegetter(prop)


for d in ["width", "height"]
  do ->
    prop = "client#{ utils.capitalize(d) }"
    Nod::[prop] = -> @node[prop]  

for d in ["top", "left", "width", "height"]
  do ->
    prop = "scroll#{ utils.capitalize(d) }"
    Nod::[prop] = -> @node[prop]  

exports.Nod = Nod

# Singleton class for document.documentElement
class Nod.Root extends Nod
  @instance: null

  constructor: ->
    throw "Nod.Root is already defined!" if Nod.Root.instance
    Nod.Root.instance = @
    super document.documentElement

  initialize: ->
    _ready_state = if document.attachEvent then 'complete' else 'interactive'

    @_loaded = document.readyState is 'complete'
    
    unless @_loaded
      @_loaded_callbacks = []
      load_handler = =>
        utils.debug 'DOM loaded'
        @_loaded = true
        @fire_all()
        NodEvent.remove window, 'load', load_handler
      NodEvent.add window, 'load', load_handler

    unless @_ready
      if document.addEventListener
        
        @_ready = document.readyState is _ready_state
        return if @_ready

        @_ready_callbacks = []
        ready_handler = =>
          utils.debug 'DOM ready'
          @_ready = true
          @fire_ready()
          document.removeEventListener 'DOMContentLoaded', ready_handler   
        document.addEventListener 'DOMContentLoaded', ready_handler
      else

        @_ready = document.readyState is _ready_state
        return if @_ready

        @_ready_callbacks = []
        ready_handler = =>
          if document.readyState is _ready_state
            utils.debug 'DOM ready'
            @_ready = true
            @fire_ready()
            document.detachEvent 'onreadystatechange', ready_handler
        document.attachEvent 'onreadystatechange', ready_handler    

  ready: (callback) ->
    if @_ready
      callback.call null
    else
      @_ready_callbacks.push callback

  loaded: (callback) ->
    if @_loaded
      callback.call null
    else
      @_loaded_callbacks.push callback

  fire_all: ->
    @fire_ready() if @_ready_callbacks
    while callback=@_loaded_callbacks.shift()
      callback.call null
    @_loaded_callbacks = null

  fire_ready: ->
    while callback=@_ready_callbacks.shift()
      callback.call null
    @_ready_callbacks = null

  scrollTop: ->
    @node.scrollTop || document.body.scrollTop
  
  scrollLeft: ->
    @node.scrollLeft || document.body.scrollLeft

  scrollHeight: ->
    @node.scrollHeight

  scrollWidth: ->
    @node.scrollWidth

  height: ->
    window.innerHeight || @node.clientHeight

  width: ->
    window.innerWidth || @node.clientWidth

class Nod.Win extends Nod
  @instance: null

  constructor: ->
    throw "Nod.Win is already defined!" if Nod.Win.instance
    Nod.Win.instance = @
    @delegate_to Nod.root, 'scrollLeft', 'scrollTop', 'scrollWidth', 'scrollHeight'
    super window

  scrollY: (y) ->
    x = @scrollLeft()
    @_with_raf 'scrollY', => @node.scrollTo(x,y)

  scrollX: (x) ->
    y = @scrollTop()
    @_with_raf 'scrollX', => @node.scrollTo(x,y)

  width: ->
    @node.innerWidth

  height: ->
    @node.innerHeight

  x: ->
    0

  y: ->
    0

# Window and body
_win = null
_body = null
Object.defineProperties(
  Nod,
  win: 
    get: -> _win ||= new Nod.Win()
  body:
    get: -> _body ||= new Nod(document.body)
)

module.exports = exports
