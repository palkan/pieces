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
        pi.Nod::[s] = (val) ->
          if val is undefined 
            return @nod["offset#{utils.camelCase(s)}"]
          @nod.style[s] = Math.round(val)+"px"
          @

  _node = (n) ->
    if n instanceof pi.Nod
      return n.node
    if typeof n is "string"
      return _fragment n
    n

  _dataCase = (str) ->
    words = str.split '-'
    words[0]+(utils.capitalize(w) for w in words[1..]).join('')

  # generate document fragment from html string

  _fragment = (html) ->
    temp = document.createElement 'div'
    temp.innerHTML = html
    f = document.createDocumentFragment()
    f.appendChild(node) for node in temp.children
    f

 
  class pi.Nod extends pi.NodEventDispatcher
    constructor: (node) ->
      @node = node
      @node._nod = @

    @create: (node='div') ->
      if node instanceof @
        return node
      if node.hasOwnProperty("_nod") 
        return node._nod
      if typeof node is 'string'
        node = document.createElement node 
      new @(node)

    @create_html: (html) ->
      temp = document.createElement 'div'
      temp.innerHTML = html
      new @(temp.firstChild)

    find: (selector) ->
      @node.querySelector selector

    each: (selector, callback) ->
      i=0
      for node in @node.querySelectorAll selector
        do ->
          callback.call null, node, i
          i++

    parent: ->
      @node.parentNode
    
    children: ->
      @node.children

    wrap: ->
      wrapper = @constructor.create 'div'  
      @node.parentNode.insertBefore wrapper.node, @node
      wrapper.append @node
      wrapper

    prepend: (node) -> 
      node = _node node
      @node.insertBefore node, @node.firstChild
      @
    
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

    detach: ->
      @node.parentNode.removeChild @node
      @

    remove: ->
      @detach()
      @html('')
      @

    clone: ->
      c = document.createElement @node.nameNode
      c.innerHTML = @node.outerHTML
      new @constructor c.firstChild

    html: (val) ->
      if val?
        @node.innerHTML = val
      else
        @node.innerHTML

    text: (val) ->
      if val?
        @node.textContent = val
      else
        @node.textContent

    addClass: (c) ->
      @node.classList.add c
      @

    removeClass: (c) ->
      @node.classList.remove c
      @

    toggleClass: (c) ->
      @node.classList.toggle c
      @

    hasClass: (c) ->
      @node.classList.contains c

    x: ->
      offset = @node.offsetLeft
      parent = @constructor @parent()
      unless parent is document 
        offset += parent.x()
      offset

    y: ->
      offset = @node.offsetTop
      parent = @parent()
      unless parent is document 
        offset += parent.y()
      offset

    show: ->
      @nod.style.display = "block"

    hide: ->
      @nod.style.display = "none"

    focus: ->
      @node.focus()
      @

    blur: ->
      @node.blur()
      @

  _prop_hash(
    "data", 
    (-> 
      if typeof DOMStringMap is "undefined" 
        (prop, val) ->  
          if prop is undefined
            dataset = {}
            for attr in @node.attributes
              if attr.name.indexOf('data-') is 0
                dataset[_dataCase(attr.name[5..])] = attr.value
            return dataset

          prop = "data-" + prop;
          unless val?
            _val = @attr prop
            if _val is null 
              _val = undefined
            if val is undefined 
              return _val
            @attr prop, null
            _val
          else
            @attr prop, val
        
      else
        (prop, val) ->
          return @node.dataset if prop is undefined

          data = @node.dataset
          if val is undefined 
            return data[prop]
          if val is null
            val = data[prop]
            delete data[prop]
            val
          else
            data[prop] = val
    )())

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

  _geometry_styles(sty) for sty in ["top", "left", "width", "height"]

  pi.Nod.root = new pi.Nod document.documentElement
