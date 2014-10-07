class pi.controllers.Perf2Controller extends pi.controllers.Base
  id: 'perf2'

  start: ->
    utils.info 'start perf2'
    @view.generate()

  stop: ->
    utils.info 'stop perf2'
    @view.remove()

_fun = (e) -> utils.debug(e.target.node._uid)

class pi.Perf2View extends pi.BaseView
  default_controller: pi.controllers.Perf2Controller

  @requires 'list'

  generate: ->
    count = 100
    while(count>0)
      count--
      @list.add_item {name: (count+1)+'', options: ['a','b','c','d','e','f','g','h','k','l','m']}

  remove: ->
    @list.clear()