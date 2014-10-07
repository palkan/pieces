class pi.resources.Perf extends pi.resources.Base
  @set_resource 'perfs'


class pi.controllers.Perf3Controller extends pi.controllers.Base
  id: 'perf3'

  start: ->
    utils.info 'start perf3'
    @view.generate()

  stop: ->
    utils.info 'stop perf3'
    @view.remove()

_fun = (e) -> utils.debug(e.target.node._uid)

class pi.Perf3View extends pi.BaseView
  default_controller: pi.controllers.Perf3Controller

  @requires 'content'

  generate: ->
    count = 100
    @tick(count)

  tick: (count) ->
    res = $r.Perf.build({name: 'name_'+count, size: count})
    @content.restful.bind res, true
    after 100, => @tick(count-1) if count>0

  remove: ->
    @content.restful.bind null