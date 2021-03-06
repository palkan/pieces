'use strict'
Controllers = require './index'
utils = require '../core/utils'
BaseView = require '../views/base'
Views = require '../views'
Initializer = require '../components/utils/initializer'
Page = require './page'

# Generate controller and view for nod.
# Return view.
# 
# Example:
# 
#   <div data-controller="base | listable(resource_name) paginated with_loader" 
#     data-pid="some"
#     data-view="| popuped" 
#     data-strategy="all_for_one"
#     data-default="main">...</div>
#   
#   Generate Base controller with listable, paginated and with_loader modules included.
#   Generate Base view with listable, paginated, with_loader and popuped modules included.
#   
#   Plugin specific options (e.g. resource_name for listable) are added to controller/view options
#   hash (i.e. options['listable']).
class ControllerBuilder
  @match: (nod) ->
    !!nod.data('controller')
  @build: (nod, host) ->
    options = Initializer.gather_options(nod)
    c_options = options.controller.split(/\s*\|\s*/)
    cklass_name = c_options[0] || 'base'
    cklass = utils.obj.get_class_path(Controllers, cklass_name)
    return utils.error("Unknown controller #{options.controller}") unless cklass?

    v_options = options.view?.split(/\s*\|\s*/) ? [cklass_name]
    vklass_name = v_options[0] || cklass_name
    vklass = utils.obj.get_class_path(Views, vklass_name) || BaseView

    # delete already used options
    delete options['view']
    delete options['controller']

    options.modules = Initializer.parse_modules((c_options[1]||'').split(/\s+/))

    controller = new cklass(utils.clone(options))

    # delete controller-only options
    delete options['strategy']
    delete options['default']

    # add view-specific modules
    utils.extend(options.modules, Initializer.parse_modules((v_options[1]||'').split(/\s+/)), true)

    view = new vklass(nod.node, host, options)
    controller.set_view view 

    host_context = if (_view = host.view) then _view.controller else Page.instance
    host_context.add_context controller, as: view.pid
    view

Initializer.insert_builder_at(ControllerBuilder, 0)

module.exports = ControllerBuilder
