class pi.controllers.Perf1Controller extends pi.controllers.Base
  id: 'perf1'

  start: ->
    utils.info 'start perf1'
    @view.generate()

  stop: ->
    utils.info 'stop perf1'
    @view.remove()

_fun = (e) -> utils.debug(e.target.node._uid)

class pi.Perf1View extends pi.BaseView
  default_controller: pi.controllers.Perf1Controller

  @requires 'content'

  generate: ->
    count = 100
    while(count>0)
      count--
      nod = pi.Nod.create("<div>Div #{count+1}</div>")
      @content.append nod
      nod.on 'click', _fun

  remove: ->
    @content.remove_children()