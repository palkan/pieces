do (context = this) ->
  "use strict"

  pi = context.pi  = context.pi || {}
  utils = pi.utils

  _prop_hash = (method, callback) ->
    pi.Nod::[method] = (prop, val) ->
      unless typeof prop is "object" 
        return callback.call @, prop, val
      for own k,p of prop
        callback.call @, k, p
      return

  _geometry_styles = (sty) ->
    for s in sty
      do ->
        name = s
        pi.Nod::[name] = (val) ->
          if val is undefined 
            return @node["offset#{utils.capitalize(name)}"]
          @node.style[name] = Math.round(val)+"px"
          @
        return
    return

  _node = (n) ->
    if n instanceof pi.Nod
      return n.node
    if typeof n is "string"
      return _fragment n
    n

  _data_reg = /^data-\w[\w\-]*$/

  # data case is: 'word1-word2-word3'
  # returns snake_case: 'word1_word2_word3'
  _from_dataCase = (str) ->
    words = str.split '-'
    words[0]+words[1..].join('_')

  _dataset = 
    (-> 
      if typeof DOMStringMap is "undefined" 
        (node) ->  
          dataset = {}
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

  # generate document fragment from html string

  _fragment = (html) ->
    temp = document.createElement 'div'
    temp.innerHTML = html
    f = document.createDocumentFragment()
    while(temp.firstChild)
      f.appendChild temp.firstChild 
    f

  class pi.Nod extends pi.NodEventDispatcher
    constructor: (@node) ->
      super
      throw Error("Node is undefined!") unless @node?

      @_disposed = false
      # virtual data element
      @_data = _dataset(node)

      @node._nod = @ unless @node._nod?

    # create new Nod from HTMLElement, HTML string, tag name or even another Nod (just returns it)

    @create: (node) ->
      switch 
        when !node then null
        when node instanceof @ then node
        when (typeof node["_nod"] isnt "undefined") then node._nod
        when utils.is_html(node) then @_create_html(node)
        when typeof node is "string" then new @(document.createElement node)
        else new @(node)

    @_create_html: (html) ->
      temp = document.createElement 'div'
      temp.innerHTML = html
      new @(temp.firstChild)

    # return first matching element as Nod

    find: (selector) ->
      pi.Nod.create @node.querySelector(selector)

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

    # return parent Element as Nod

    parent: (selector) ->
      unless selector?
        pi.Nod.create @node.parentNode
      else
        p = @node
        while((p = p.parentNode) && (p != document))
          if p.matches(selector)
            return pi.Nod.create p
        return null

    # return children Elements without modifying 

    children: (callback) ->
      if typeof callback is 'function'
        i=0
        for n in @node.children
          break if callback.call(null, n, i) is true
          i++
        @
      else
        @node.children

    # wrap node in a DIV with klasses

    wrap: (klasses...) ->
      wrapper = pi.Nod.create 'div'
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
      @node.parentNode.removeChild @node
      @

    # detach all node children

    detach_children: ->
      while @node.children.length
        @node.removeChild @node.children[0]
      @

    # detach and dispose
    # return null

    remove: ->
      @detach()
      @html('')
      @dispose()
      null

    # clear contents of node (equals html(''))
    empty: ->
      @html ''
      @

    clone: ->
      c = document.createElement @node.nameNode
      c.innerHTML = @node.outerHTML
      new pi.Nod(c.firstChild)


    # remove event listeners and internal links
    # GC should collect thid Nod if there is no external links

    dispose: ->
      @off()
      delete @node._nod
      delete @node
      @_data = null
      @_disposed = true
      return

    html: (val) ->
      if val?
        @node.innerHTML = val
        @
      else
        @node.innerHTML

    text: (val) ->
      if val?
        @node.textContent = val
        @
      else
        @node.textContent

    value: (val) ->
      if val?
        @node.value = val
        @
      else
        @node.value

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

    move: (x,y) ->
      @style left: x, top: y

    position: () ->
      x: @x(), y: @y() 

    offset: () ->
      x: @node.offsetLeft, y: @node.offsetTop 

    size: (width = null, height = null) ->
      unless width? and height?
        return width: @width(), height: @height()
      
      if width? and height?
        @width width
        @height height
      else
        old_h = @height()
        old_w = @width()
        if width?
          @width width
          @height (old_h * width/old_w)
        else
          @height height
          @width (old_w * height/old_h)
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

      if val is undefined 
        return @_data[prop]
      if val is null
        val = @_data[prop]
        delete @_data[prop]
        val
      else
        @_data[prop] = val
        @
  )

  _prop_hash(
    "style", 
    (prop, val) -> 
      if val is undefined 
        return @node.style[prop]
      @node.style[prop] = val
  )

  _prop_hash(
    "attr", 
    (prop, val) ->
      if val is undefined 
        return @node.getAttribute prop
      if val is null 
        @node.removeAttribute prop
      
      @node.setAttribute prop, val
  )

  _geometry_styles ["top", "left", "width", "height"]

  for d in ["top", "left", "width", "height"]
    prop = "scroll#{ utils.capitalize(d) }"
    pi.Nod::[prop] = -> @node[prop]  


  #singleton class for document.documentElement

  class pi.NodRoot extends pi.Nod
    @instance: null

    constructor: ->
      throw "NodRoot is already defined!" if pi.NodRoot.instance
      pi.NodRoot.instance = @
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
          pi.NodEvent.remove window, 'load', load_handler
        pi.NodEvent.add window, 'load', load_handler

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

  pi.Nod.root = new pi.NodRoot()
  pi.Nod.win = new pi.Nod window
  pi.Nod.body = new pi.Nod document.body
  
  pi.Nod.root.initialize()

