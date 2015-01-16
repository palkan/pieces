(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
'use strict';
var pi, utils;

pi = require('../core/pi');

utils = pi.utils;

pi.App = (function() {
  function App() {}

  App.prototype.initialize = function(nod) {
    var _ref;
    this.view = pi.piecify(nod || pi.Nod.root);
    return (_ref = this.page) != null ? _ref.initialize() : void 0;
  };

  return App;

})();

pi.app = new pi.App();

module.exports = pi.app;



},{"../core/pi":36}],2:[function(require,module,exports){
'use strict';
var Init, Nod, pi, utils, _array_rxp,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __slice = [].slice;

pi = require('../../core');

require('./setup');

require('./compiler');

require('./klass');

require('../events');

utils = pi.utils;

Nod = pi.Nod;

Init = pi.ComponentInitializer;

_array_rxp = /\[\]$/;

pi.Base = (function(_super) {
  __extends(Base, _super);

  Base.include_plugins = function() {
    var plugin, plugins, _i, _len, _results;
    plugins = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    _results = [];
    for (_i = 0, _len = plugins.length; _i < _len; _i++) {
      plugin = plugins[_i];
      _results.push(plugin.included(this));
    }
    return _results;
  };

  Base.requires = function() {
    var components;
    components = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return this.before_create(function() {
      var cmp, _results;
      _results = [];
      while (components.length) {
        cmp = components.pop();
        if (this[cmp] === void 0) {
          throw Error("Missing required component " + cmp);
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    });
  };

  function Base(node, host, options) {
    this.node = node;
    this.host = host;
    this.options = options != null ? options : {};
    Base.__super__.constructor.apply(this, arguments);
    this.preinitialize();
    this.initialize();
    this.init_plugins();
    this.init_children();
    this.setup_events();
    this.postinitialize();
  }

  Base.prototype.piecify = function() {
    var c, _i, _len, _ref, _results;
    this.__components__.length = 0;
    this.init_children();
    _ref = this.__components__;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      c = _ref[_i];
      _results.push(c.piecify());
    }
    return _results;
  };

  Base.prototype.trigger = function(event, data, bubbles) {
    if (this.enabled || event === pi.Events.Enabled) {
      return Base.__super__.trigger.call(this, event, data, bubbles);
    }
  };

  Base.prototype.bubble_event = function(event) {
    if (this.host != null) {
      return this.host.trigger(event);
    }
  };

  Base.prototype.show = function() {
    if (!this.visible) {
      this.removeClass(pi.klass.HIDDEN);
      this.visible = true;
      this.trigger(pi.Events.Hidden, false);
    }
    return this;
  };

  Base.prototype.hide = function() {
    if (this.visible) {
      this.addClass(pi.klass.HIDDEN);
      this.visible = false;
      this.trigger(pi.Events.Hidden, true);
    }
    return this;
  };

  Base.prototype.enable = function() {
    if (!this.enabled) {
      this.removeClass(pi.klass.DISABLED);
      this.enabled = true;
      this.trigger(pi.Events.Enabled, true);
    }
    return this;
  };

  Base.prototype.disable = function() {
    if (this.enabled) {
      this.addClass(pi.klass.DISABLED);
      this.enabled = false;
      this.trigger(pi.Events.Enabled, false);
    }
    return this;
  };

  Base.prototype.activate = function() {
    if (!this.active) {
      this.addClass(pi.klass.ACTIVE);
      this.active = true;
      this.trigger(pi.Events.Active, true);
    }
    return this;
  };

  Base.prototype.deactivate = function() {
    if (this.active) {
      this.removeClass(pi.klass.ACTIVE);
      this.active = false;
      this.trigger(pi.Events.Active, false);
    }
    return this;
  };

  Base.prototype.preinitialize = function() {
    this.node._nod = this;
    this.__components__ = [];
    this.__plugins__ = [];
    this.pid = this.data('pid') || this.attr('pid') || this.node.id;
    this.visible = this.enabled = true;
    return this.active = false;
  };

  Base.prototype.initialize = function() {
    if (this.options.disabled || this.hasClass(pi.klass.DISABLED)) {
      this.disable();
    }
    if (this.options.hidden || this.hasClass(pi.klass.HIDDEN)) {
      this.hide();
    }
    if (this.options.active || this.hasClass(pi.klass.ACTIVE)) {
      this.activate();
    }
    this._initialized = true;
    return this.trigger(pi.Events.Initialized, true, false);
  };

  Base.register_callback('initialize');

  Base.prototype.init_plugins = function() {
    var name, _i, _len, _ref;
    if (this.options.plugins != null) {
      _ref = this.options.plugins;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        name = _ref[_i];
        this.attach_plugin(this.find_plugin(name));
      }
      delete this.options.plugins;
    }
  };

  Base.prototype.attach_plugin = function(plugin) {
    if (plugin != null) {
      utils.debug_verbose("plugin attached " + plugin.prototype.id);
      return this.__plugins__.push(plugin.attached(this));
    }
  };

  Base.prototype.find_plugin = function(name) {
    var klass, _ref;
    name = utils.camelCase(name);
    klass = this.constructor;
    while ((klass != null)) {
      if (klass[name] != null) {
        return klass[name];
      }
      klass = (_ref = klass.__super__) != null ? _ref.constructor : void 0;
    }
    utils.warning("plugin not found: " + name);
    return null;
  };

  Base.prototype.init_children = function() {
    var node, _fn, _i, _len, _ref;
    _ref = this.find_cut("." + pi.klass.PI);
    _fn = (function(_this) {
      return function(node) {
        var arr, child, _name;
        child = Init.init(node, _this);
        if (child != null ? child.pid : void 0) {
          if (_array_rxp.test(child.pid)) {
            arr = (_this[_name = child.pid.slice(0, -2)] || (_this[_name] = []));
            if (!(arr.indexOf(child) > -1)) {
              arr.push(child);
            }
          } else {
            _this[child.pid] = child;
          }
          return _this.__components__.push(child);
        }
      };
    })(this);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      node = _ref[_i];
      _fn(node);
    }
  };

  Base.prototype.setup_events = function() {
    var event, handler, handlers, _i, _len, _ref, _ref1;
    _ref = this.options.events;
    for (event in _ref) {
      handlers = _ref[event];
      _ref1 = handlers.split(/;\s*/);
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        handler = _ref1[_i];
        this.on(event, pi.Compiler.str_to_event_handler(handler, this));
      }
    }
    delete this.options.events;
  };

  Base.prototype.postinitialize = function() {
    return this.trigger(pi.Events.Created, true, false);
  };

  Base.register_callback('postinitialize', {
    as: 'create'
  });

  Base.prototype.dispose = function() {
    var plugin, _i, _len, _ref;
    if (this._disposed) {
      return;
    }
    if (this.host != null) {
      this.host.remove_component(this);
    }
    _ref = this.__plugins__;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      plugin = _ref[_i];
      plugin.dispose();
    }
    this.__plugins__.length = 0;
    Base.__super__.dispose.apply(this, arguments);
    this.trigger(pi.Events.Destroyed, true, false);
  };

  Base.prototype.remove_component = function(child) {
    if (!child.pid) {
      return;
    }
    if (_array_rxp.test(child.pid)) {
      if (this["" + child.pid.slice(0, -2)]) {
        delete this["" + child.pid.slice(0, -2)];
      }
    } else {
      delete this[child.pid];
    }
    return this.__components__.splice(this.__components__.indexOf(child), 1);
  };

  Base.prototype.remove_children = function() {
    var child, list, _i, _len;
    list = this.__components__.slice();
    for (_i = 0, _len = list.length; _i < _len; _i++) {
      child = list[_i];
      this.remove_component(child);
      child.remove();
    }
    return Base.__super__.remove_children.apply(this, arguments);
  };

  return Base;

})(pi.Nod);



},{"../../core":34,"../events":12,"./compiler":4,"./klass":7,"./setup":9}],3:[function(require,module,exports){
'use strict';
var pi, utils, _pass, _serialize,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

pi = require('../../core');

require('./base');

require('../events/input_events');

utils = pi.utils;

_pass = function(val) {
  return val;
};

_serialize = function(val) {
  return utils.serialize(val);
};

pi.BaseInput = (function(_super) {
  __extends(BaseInput, _super);

  function BaseInput() {
    return BaseInput.__super__.constructor.apply(this, arguments);
  }

  BaseInput.prototype.postinitialize = function() {
    this.input || (this.input = this.node.nodeName === 'INPUT' ? this : this.find('input'));
    if (this.options.serialize === true) {
      this._serializer = _serialize;
    } else {
      this._serializer = _pass;
    }
    if ((this.options.default_value != null) && !utils.serialize(this.value())) {
      return this.value(this.options.default_value);
    }
  };

  BaseInput.prototype.value = function(val) {
    if (val != null) {
      this.input.node.value = val;
      return this;
    } else {
      return this._serializer(this.input.node.value);
    }
  };

  BaseInput.prototype.clear = function(silent) {
    if (silent == null) {
      silent = false;
    }
    if (this.options.default_value != null) {
      this.value(this.options.default_value);
    } else {
      this.value('');
    }
    if (!silent) {
      return this.trigger(pi.InputEvent.Clear);
    }
  };

  return BaseInput;

})(pi.Base);



},{"../../core":34,"../events/input_events":13,"./base":2}],4:[function(require,module,exports){
'use strict';
var CompiledFun, parser, pi, utils, _error, _null, _operators, _true, _view_context_mdf,
  __slice = [].slice;

pi = require('../../core');

parser = require('../../grammar/pi_grammar').parser;

utils = pi.utils;

_true = function() {
  return true;
};

_null = function() {};

_error = function(fun_str) {
  utils.error("Function [" + fun_str + "] was compiled with error");
  return false;
};

_operators = {
  ">": function(a, b) {
    return a > b;
  },
  "<": function(a, b) {
    return a < b;
  },
  "=": function(a, b) {
    return a === b;
  },
  "bool": function(a) {
    return !!a;
  }
};

CompiledFun = (function() {
  function CompiledFun(target, fun_str) {
    var e;
    this.target = target != null ? target : {};
    this.fun_str = fun_str;
    try {
      this._parsed = parser.parse(fun_str);
    } catch (_error) {
      e = _error;
      this._compiled = utils.curry(_error, [fun_str]);
    }
  }

  CompiledFun.prototype.call = function() {
    var args, ths;
    ths = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    return this.apply(ths, args);
  };

  CompiledFun.prototype.apply = function(ths, args) {
    this.call_ths = ths || {};
    return this.compiled().apply(this, args);
  };

  CompiledFun.prototype.compiled = function() {
    return this._compiled || (this._compiled = this._compile_fun());
  };

  CompiledFun.prototype._compile_fun = function() {
    return (function(_this) {
      return function() {
        return _this["_get_" + _this._parsed.code](_this._parsed);
      };
    })(this);
  };

  CompiledFun.prototype._get_chain = function(data) {
    var frst, i, step, _target;
    frst = data.value[0];
    _target = (function() {
      var _base;
      switch (frst.name) {
        case 'this':
          return this.target;
        case 'app':
          return pi.app;
        case 'host':
          return this.target.host;
        case 'view':
          return typeof (_base = this.target).view === "function" ? _base.view() : void 0;
        default:
          return this["_get_" + frst.code](frst, this.call_ths) || this["_get_" + frst.code](frst, window);
      }
    }).call(this);
    i = 1;
    while (i < data.value.length) {
      step = data.value[i++];
      _target = this["_get_" + step.code](step, _target);
    }
    return _target;
  };

  CompiledFun.prototype._get_res = function(data, from) {
    if (from == null) {
      from = {};
    }
    return from[data.name] || pi.resources[data.name];
  };

  CompiledFun.prototype._get_prop = function(data, from) {
    return from[data.name];
  };

  CompiledFun.prototype._get_call = function(data, from) {
    return from[data.name].apply(from, this._get_args(data.args));
  };

  CompiledFun.prototype._get_args = function(args) {
    var arg, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = args.length; _i < _len; _i++) {
      arg = args[_i];
      _results.push(this["_get_" + arg.code](arg));
    }
    return _results;
  };

  CompiledFun.prototype._get_if = function(data) {
    var _left, _right;
    _left = data.cond.left;
    _right = data.cond.right;
    _left = this["_get_" + _left.code](_left);
    if (_right != null) {
      _right = this["_get_" + _right.code](_right);
    }
    if (_operators[data.cond.type](_left, _right)) {
      return this["_get_" + data.left.code](data.left);
    } else if (data.right != null) {
      return this["_get_" + data.right.code](data.right);
    } else {
      return false;
    }
  };

  CompiledFun.prototype._get_simple = function(data) {
    return data.value;
  };

  return CompiledFun;

})();

pi.Compiler = (function() {
  function Compiler() {}

  Compiler.modifiers = [];

  Compiler.process_modifiers = function(str) {
    var fun, _i, _len, _ref;
    _ref = this.modifiers;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      fun = _ref[_i];
      str = fun.call(null, str);
    }
    return str;
  };

  Compiler.compile_fun = function(callstr, target) {
    callstr = this.process_modifiers(callstr);
    return new CompiledFun(target, callstr);
  };

  Compiler.str_to_fun = Compiler.compile_fun;

  Compiler.str_to_event_handler = function(callstr, host) {
    var _f;
    _f = this.compile_fun(callstr, host);
    return function(e) {
      return _f.call({
        e: e
      });
    };
  };

  return Compiler;

})();

_view_context_mdf = function(str) {
  return str.replace(/@(this|app|host|view)(\b)/g, '$1$2').replace(/@@/g, 'pi.app.page.context.').replace(/@/g, 'pi.app.view.');
};

pi.Compiler.modifiers.push(_view_context_mdf);

pi.call = pi.Compiler.call;



},{"../../core":34,"../../grammar/pi_grammar":48}],5:[function(require,module,exports){
'use strict';
require('./base');

require('./base_input');

require('./list');

require('./textinput');



},{"./base":2,"./base_input":3,"./list":8,"./textinput":10}],6:[function(require,module,exports){
'use strict';
var event_re, pi, utils;

pi = require('../../core');

utils = pi.utils;

event_re = /^on_(.+)/i;

pi.ComponentInitializer = (function() {
  function ComponentInitializer() {}

  ComponentInitializer.guess_component = function(nod) {
    var component, component_name;
    component_name = nod.data('component') || pi.Guesser.find(nod);
    component = utils.obj.get_class_path(pi, component_name);
    if (component == null) {
      return utils.error("Unknown component " + component_name, nod.data());
    } else {
      component.class_name = component_name;
      utils.debug_verbose("Component created: " + component_name);
      return component;
    }
  };

  ComponentInitializer.gather_options = function(el, component_name) {
    var key, matches, opts, val;
    if (component_name == null) {
      component_name = "base";
    }
    opts = utils.clone(el.data());
    opts.plugins = opts.plugins != null ? opts.plugins.split(/\s+/) : null;
    opts.events = {};
    for (key in opts) {
      val = opts[key];
      if (matches = key.match(event_re)) {
        opts.events[matches[1]] = val;
      }
    }
    return utils.merge(pi.config[component_name] || {}, opts);
  };

  ComponentInitializer.init = function(nod, host) {
    var component;
    nod = nod instanceof pi.Nod ? nod : pi.Nod.create(nod);
    component = this.guess_component(nod);
    if (component == null) {
      return;
    }
    if (nod instanceof component) {
      return nod;
    } else {
      return new component(nod.node, host, this.gather_options(nod, component.class_name));
    }
  };

  return ComponentInitializer;

})();



},{"../../core":34}],7:[function(require,module,exports){
'use strict';
var pi;

pi = require('../../core');

pi.klass = {
  PI: 'pi',
  DISABLED: 'is-disabled',
  HIDDEN: 'is-hidden',
  ACTIVE: 'is-active',
  READONLY: 'is-readonly',
  INVALID: 'is-invalid',
  SELECTED: 'is-selected',
  LIST: 'list',
  LIST_ITEM: 'item',
  FILTERED: 'is-filtered',
  SEARCHING: 'is-searching',
  EMPTY: 'is-empty'
};



},{"../../core":34}],8:[function(require,module,exports){
'use strict';
var pi, utils,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

pi = require('../../core');

require('./base');

require('../events/list_events');

require('../../plugins/base/renderable');

utils = pi.utils;

pi.List = (function(_super) {
  __extends(List, _super);

  function List() {
    return List.__super__.constructor.apply(this, arguments);
  }

  List.include_plugins(pi.Base.Renderable);

  List.prototype.merge_classes = [pi.klass.DISABLED, pi.klass.ACTIVE, pi.klass.HIDDEN];

  List.prototype.preinitialize = function() {
    List.__super__.preinitialize.apply(this, arguments);
    this.list_klass = this.options.list_klass || pi.klass.LIST;
    this.item_klass = this.options.item_klass || pi.klass.LIST_ITEM;
    this.items = [];
    return this.buffer = document.createDocumentFragment();
  };

  List.prototype.initialize = function() {
    List.__super__.initialize.apply(this, arguments);
    this.items_cont = this.find("." + this.list_klass) || this;
    return this.parse_html_items();
  };

  List.prototype.postinitialize = function() {
    this._check_empty();
    if (this.options.noclick == null) {
      return this.listen("." + this.item_klass, 'click', (function(_this) {
        return function(e) {
          if (!utils.is_clickable(e.origTarget)) {
            if (_this._item_clicked(e.target)) {
              return e.cancel();
            }
          }
        };
      })(this));
    }
  };

  List.prototype.parse_html_items = function() {
    this.items_cont.each("." + this.item_klass, (function(_this) {
      return function(node) {
        return _this.add_item(pi.Nod.create(node), true);
      };
    })(this));
    return this._flush_buffer();
  };

  List.prototype.data_provider = function(data, silent, remove) {
    var item, _i, _len;
    if (data == null) {
      data = null;
    }
    if (silent == null) {
      silent = false;
    }
    if (remove == null) {
      remove = true;
    }
    if (this.items.length) {
      this.clear(silent, remove);
    }
    if (data != null) {
      for (_i = 0, _len = data.length; _i < _len; _i++) {
        item = data[_i];
        this.add_item(item, true);
      }
    }
    this.update('load', silent);
    return this;
  };

  List.prototype.add_item = function(data, silent) {
    var item;
    if (silent == null) {
      silent = false;
    }
    item = this._create_item(data, this.items.length);
    if (item == null) {
      return;
    }
    this.items.push(item);
    this._check_empty();
    if (!silent) {
      this.items_cont.append(item);
    } else {
      this.buffer.appendChild(item.node);
    }
    if (!silent) {
      this.trigger(pi.ListEvent.Update, {
        type: pi.ListEvent.ItemAdded,
        item: item
      });
    }
    return item;
  };

  List.prototype.add_item_at = function(data, index, silent) {
    var item, _after;
    if (silent == null) {
      silent = false;
    }
    if (this.items.length - 1 < index) {
      return this.add_item(data, silent);
    }
    item = this._create_item(data, index);
    this.items.splice(index, 0, item);
    _after = this.items[index + 1];
    item.record.__list_index__ = index;
    _after.insertBefore(item);
    this._need_update_indeces = true;
    if (!silent) {
      this._update_indeces();
      this.trigger(pi.ListEvent.Update, {
        type: pi.ListEvent.ItemAdded,
        item: item
      });
    }
    return item;
  };

  List.prototype.remove_item = function(item, silent, destroy) {
    var index;
    if (silent == null) {
      silent = false;
    }
    if (destroy == null) {
      destroy = true;
    }
    index = this.items.indexOf(item);
    if (index > -1) {
      this.items.splice(index, 1);
      if (destroy) {
        this._destroy_item(item);
      } else {
        item.detach();
      }
      this._check_empty();
      this._need_update_indeces = true;
      if (!silent) {
        this._update_indeces();
        this.trigger(pi.ListEvent.Update, {
          type: pi.ListEvent.ItemRemoved,
          item: item
        });
      }
      return true;
    } else {
      return false;
    }
  };

  List.prototype.remove_item_at = function(index, silent) {
    var item;
    if (silent == null) {
      silent = false;
    }
    if (this.items.length - 1 < index) {
      return;
    }
    item = this.items[index];
    return this.remove_item(item, silent);
  };

  List.prototype.remove_items = function(items) {
    var item, _i, _len;
    for (_i = 0, _len = items.length; _i < _len; _i++) {
      item = items[_i];
      this.remove_item(item, true);
    }
    this.update();
  };

  List.prototype.update_item = function(item, data, silent) {
    var klass, new_item, _i, _len, _ref;
    if (silent == null) {
      silent = false;
    }
    new_item = this._renderer.render(data, false);
    utils.extend(item.record, new_item.record, true);
    item.remove_children();
    item.html(new_item.html());
    _ref = item.node.className.split(/\s+/);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      klass = _ref[_i];
      if (klass && !(__indexOf.call(this.merge_classes, klass) >= 0)) {
        item.removeClass(klass);
      }
    }
    item.mergeClasses(new_item);
    item.piecify();
    item.postinitialize();
    if (!silent) {
      this.trigger(pi.ListEvent.Update, {
        type: pi.ListEvent.ItemUpdated,
        item: item
      });
    }
    return item;
  };

  List.prototype.move_item = function(item, index) {
    var _after;
    if ((item.record.__list_index__ === index) || (index > this.items.length - 1)) {
      return;
    }
    this.items.splice(this.items.indexOf(item), 1);
    if (index === this.items.length) {
      this.items.push(item);
      this.items_cont.append(item);
    } else {
      this.items.splice(index, 0, item);
      _after = this.items[index + 1];
      _after.insertBefore(item);
    }
    this._need_update_indeces = true;
    this._update_indeces();
    return item;
  };

  List.prototype.where = function(query) {
    var item, matcher, _i, _len, _ref, _results;
    matcher = typeof query === "string" ? utils.matchers.nod(query) : utils.matchers.object(query);
    _ref = this.items;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      item = _ref[_i];
      if (matcher(item)) {
        _results.push(item);
      }
    }
    return _results;
  };

  List.prototype.records = function() {
    return this.items.map(function(item) {
      return item.record;
    });
  };

  List.prototype.size = function() {
    return this.items.length;
  };

  List.prototype.update = function(type, silent) {
    if (silent == null) {
      silent = false;
    }
    this._flush_buffer();
    if (this._need_update_indeces) {
      this._update_indeces();
    }
    this._check_empty(silent);
    if (!silent) {
      return this.trigger(pi.ListEvent.Update, {
        type: type
      });
    }
  };

  List.prototype.clear = function(silent, remove) {
    if (silent == null) {
      silent = false;
    }
    if (remove == null) {
      remove = true;
    }
    if (!remove) {
      this.items_cont.detach_children();
    }
    if (remove) {
      this.items_cont.remove_children();
    }
    this.items.length = 0;
    if (!silent) {
      this.trigger(pi.ListEvent.Update, {
        type: pi.ListEvent.Clear
      });
    }
    return this._check_empty(silent);
  };

  List.prototype._update_indeces = function() {
    var i, item, _i, _len, _ref;
    _ref = this.items;
    for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
      item = _ref[i];
      item.record.__list_index__ = i;
    }
    return this._need_update_indeces = false;
  };

  List.prototype._check_empty = function(silent) {
    if (silent == null) {
      silent = false;
    }
    if (!this.empty && this.items.length === 0) {
      this.addClass(pi.klass.EMPTY);
      this.empty = true;
      if (!silent) {
        return this.trigger(pi.ListEvent.Empty, true);
      }
    } else if (this.empty && this.items.length > 0) {
      this.removeClass(pi.klass.EMPTY);
      this.empty = false;
      if (!silent) {
        return this.trigger(pi.ListEvent.Empty, false);
      }
    }
  };

  List.prototype._create_item = function(data, index) {
    var item;
    if (data == null) {
      data = {};
    }
    if (data instanceof pi.Nod && data.is_list_item) {
      if (data.host === this) {
        data.__list_index__ = index;
        return data;
      } else {
        return null;
      }
    }
    if (data instanceof pi.Nod) {
      data.data('__list_index__', index);
    } else {
      data.__list_index__ = index;
    }
    item = this._renderer.render(data, true, this);
    if (item == null) {
      return;
    }
    item.record || (item.record = {});
    item.is_list_item = true;
    return item;
  };

  List.prototype._destroy_item = function(item) {
    return item.remove();
  };

  List.prototype._flush_buffer = function(append) {
    var _results;
    if (append == null) {
      append = true;
    }
    if (append) {
      this.items_cont.append(this.buffer);
    }
    _results = [];
    while (this.buffer.firstChild) {
      _results.push(this.buffer.removeChild(this.buffer.firstChild));
    }
    return _results;
  };

  List.prototype._item_clicked = function(target) {
    var item;
    if (!target.is_list_item) {
      return;
    }
    item = target;
    if (item && item.host === this) {
      this.trigger(pi.ListEvent.ItemClick, {
        item: item
      });
      return true;
    }
  };

  return List;

})(pi.Base);



},{"../../core":34,"../../plugins/base/renderable":54,"../events/list_events":14,"./base":2}],9:[function(require,module,exports){
'use strict';
var pi, utils;

pi = require('../../core');

require('./initializer');

require('./klass');

utils = pi.utils;

utils.extend(pi.Nod.prototype, {
  find_cut: function(selector) {
    var acc, el, rest;
    rest = [];
    acc = [];
    el = this.node.firstChild;
    while (el) {
      if (el.nodeType !== 1) {
        el = el.nextSibling || rest.shift();
        continue;
      }
      if (el.matches(selector)) {
        acc.push(el);
      } else {
        el.firstChild && rest.unshift(el.firstChild);
      }
      el = el.nextSibling || rest.shift();
    }
    return acc;
  }
});

pi.piecify = function(nod, host) {
  return pi.ComponentInitializer.init(nod, host || nod.parent(pi.klass.PI));
};

pi.event = new pi.EventDispatcher();

pi.find = function(pid_path, from) {
  return utils.obj.get_path(pi.app.view, pid_path);
};

utils.extend(pi.Nod.prototype, {
  piecify: function(host) {
    return pi.piecify(this, host);
  },
  pi_call: function(target, action) {
    if (!this._pi_call || this._pi_action !== action) {
      this._pi_action = action;
      this._pi_call = pi.Compiler.str_to_fun(action, target);
    }
    return this._pi_call.call(null);
  }
});

pi.Nod.root.ready(function() {
  return pi.Nod.root.listen('a', 'click', function(e) {
    if (e.target.attr("href")[0] === "@") {
      e.cancel();
      utils.debug("handle pi click: " + (e.target.attr("href")));
      e.target.pi_call(e.target, e.target.attr("href"));
    }
  });
});

pi.$ = function(q) {
  if (q[0] === '@') {
    return pi.find(q.slice(1));
  } else if (utils.is_html(q)) {
    return pi.Nod.create(q);
  } else {
    return pi.Nod.root.find(q);
  }
};

pi["export"](pi.$, '$');



},{"../../core":34,"./initializer":6,"./klass":7}],10:[function(require,module,exports){
'use strict';
var pi, utils,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

pi = require('../../core');

require('./base');

require('./base_input');

require('../events/input_events');

utils = pi.utils;

pi.TextInput = (function(_super) {
  __extends(TextInput, _super);

  function TextInput() {
    return TextInput.__super__.constructor.apply(this, arguments);
  }

  TextInput.prototype.postinitialize = function() {
    TextInput.__super__.postinitialize.apply(this, arguments);
    this.editable = true;
    if (this.options.readonly || this.hasClass(pi.klass.READONLY)) {
      this.readonly();
    }
    return this.input.on('change', (function(_this) {
      return function(e) {
        e.cancel();
        return _this.trigger(pi.InputEvent.Change, _this.value());
      };
    })(this));
  };

  TextInput.prototype.edit = function() {
    if (!this.editable) {
      this.input.attr('readonly', null);
      this.removeClass(pi.klass.READONLY);
      this.editable = true;
      this.trigger(pi.InputEvent.Editable, true);
    }
    return this;
  };

  TextInput.prototype.readonly = function() {
    if (this.editable) {
      this.input.attr('readonly', 'readonly');
      this.addClass(pi.klass.READONLY);
      this.editable = false;
      this.blur();
      this.trigger(pi.InputEvent.Editable, false);
    }
    return this;
  };

  return TextInput;

})(pi.BaseInput);



},{"../../core":34,"../events/input_events":13,"./base":2,"./base_input":3}],11:[function(require,module,exports){
'use strict';
var pi, utils, _type_rxp;

pi = require('../../core');

require('./base_input');

utils = pi.utils;

_type_rxp = /(\w+)(?:\(([\w\-\/]+)\))/;

pi.BaseInput.Validator = (function() {
  function Validator() {}

  Validator.add = function(name, fun) {
    return this[name] = fun;
  };

  Validator.validate = function(type, nod, form) {
    var data, matches;
    if ((matches = type.match(_type_rxp))) {
      type = matches[1];
      data = utils.serialize(matches[2]);
    }
    return this[type](nod.value(), nod, form, data);
  };

  Validator.email = function(val) {
    return utils.is_email(val);
  };

  Validator.len = function(val, nod, form, data) {
    return (val + "").length >= data;
  };

  Validator.truth = function(val) {
    return !!utils.serialize(val);
  };

  Validator.presence = function(val) {
    return val && ((val + "").length > 0);
  };

  Validator.digital = function(val) {
    return utils.is_digital(val + "");
  };

  Validator.confirm = function(val, nod, form) {
    var conf_nod, confirm_name;
    confirm_name = nod.name().replace(/([\]]+)?$/, "_confirmation$1");
    conf_nod = form.find_by_name(confirm_name);
    if (conf_nod == null) {
      return false;
    }
    return conf_nod.value() === val;
  };

  return Validator;

})();



},{"../../core":34,"./base_input":3}],12:[function(require,module,exports){
require('./pi_events')
require('./input_events')
require('./list_events')
},{"./input_events":13,"./list_events":14,"./pi_events":15}],13:[function(require,module,exports){
'use strict';
var pi;

pi = require('../../core');

pi.InputEvent = {
  Change: 'changed',
  Clear: 'cleared',
  Editable: 'editable'
};

pi.FormEvent = {
  Update: 'updated',
  Submit: 'submited',
  Invalid: 'invalid'
};



},{"../../core":34}],14:[function(require,module,exports){
'use strict';
var pi;

pi = require('../../core');

pi.ListEvent = {
  Update: 'update',
  ItemAdded: 'item_added',
  ItemRemoved: 'item_removed',
  ItemUpdated: 'item_updated',
  Clear: 'clear',
  Load: 'load',
  Empty: 'empty',
  ItemClick: 'item_click',
  Filtered: 'filetered',
  Searched: 'searched',
  ScrollEnd: 'scroll_end',
  Sorted: 'sorted'
};



},{"../../core":34}],15:[function(require,module,exports){
'use strict';
var pi, utils;

pi = require('../../core');

utils = pi.utils;

pi.Events = {
  Initialized: 'initialized',
  Created: 'creation_complete',
  Destroyed: 'destroyed',
  Enabled: 'enabled',
  Hidden: 'hidden',
  Active: 'active',
  Selected: 'selected',
  Update: 'update',
  SelectionCleared: 'selection_cleared'
};



},{"../../core":34}],16:[function(require,module,exports){
'use strict';
var Validator, pi, utils, _array_name,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

pi = require('../core');

require('./events/input_events');

require('./base/validator');

utils = pi.utils;

Validator = pi.BaseInput.Validator;

_array_name = function(name) {
  return name.indexOf('[]') > -1;
};

pi.Form = (function(_super) {
  __extends(Form, _super);

  function Form() {
    return Form.__super__.constructor.apply(this, arguments);
  }

  Form.prototype.postinitialize = function() {
    Form.__super__.postinitialize.apply(this, arguments);
    this._cache = {};
    this._value = {};
    this._invalids = [];
    this.former = new pi.Former(this.node, this.options);
    this.read_values();
    this.on(pi.InputEvent.Change, (function(_this) {
      return function(e) {
        e.cancel();
        if (_this.validate_nod(e.target)) {
          return _this.update_value(e.target.name(), e.data);
        }
      };
    })(this));
    this.on('change', (function(_this) {
      return function(e) {
        if (!utils.is_input(e.target.node)) {
          return;
        }
        if (_this.validate_nod(e.target)) {
          return _this.update_value(e.target.node.name, _this.former._parse_nod_value(e.target.node));
        }
      };
    })(this));
    this.form = this.node.nodeName === 'FORM' ? this : this.find('form');
    if (this.form != null) {
      return this.form.on('submit', (function(_this) {
        return function(e) {
          e.cancel();
          return _this.submit();
        };
      })(this));
    }
  };

  Form.prototype.submit = function() {
    this.read_values();
    if (this.validate() === true) {
      return this.trigger(pi.FormEvent.Submit, this._value);
    }
  };

  Form.prototype.value = function(val) {
    if (val != null) {
      this._value = {};
      this.former.traverse_nodes(this.node, (function(_this) {
        return function(node) {
          return _this.fill_value(node, val);
        };
      })(this));
      this.read_values();
      return this;
    } else {
      return this._value;
    }
  };

  Form.prototype.clear = function(silent) {
    if (silent == null) {
      silent = false;
    }
    this._value = {};
    this.former.traverse_nodes(this.node, (function(_this) {
      return function(node) {
        return _this.clear_value(node);
      };
    })(this));
    if (this.former.options.clear_hidden === false) {
      this.read_values();
    }
    if (!silent) {
      return this.trigger(pi.InputEvent.Clear);
    }
  };

  Form.prototype.read_values = function() {
    var _name_values;
    _name_values = [];
    this.former.traverse_nodes(this.node, (function(_this) {
      return function(node) {
        var nod;
        if (((nod = node._nod) instanceof pi.BaseInput) && nod.name()) {
          if (!_array_name(name)) {
            _this._cache[nod.name()] = nod;
          }
          return _name_values.push({
            name: nod.name(),
            value: nod.value()
          });
        } else if (utils.is_input(node) && node.name) {
          if (!_array_name(node.name)) {
            _this._cache[node.name] = pi.Nod.create(node);
          }
          return _name_values.push({
            name: node.name,
            value: _this.former._parse_nod_value(node)
          });
        }
      };
    })(this));
    return this._value = this.former.process_name_values(_name_values);
  };

  Form.prototype.find_by_name = function(name) {
    var nod;
    if (this._cache[name] != null) {
      return this._cache[name];
    }
    nod = this.find("[name=" + name + "]");
    if (nod != null) {
      return (this._cache[name] = nod);
    }
  };

  Form.prototype.fill_value = function(node, val) {
    var nod;
    if (((nod = node._nod) instanceof pi.BaseInput) && nod.name()) {
      val = this.former._nod_data_value(nod.name(), val);
      if (val == null) {
        return;
      }
      return nod.value(val);
    } else if (utils.is_input(node)) {
      return this.former._fill_nod(node, val);
    }
  };

  Form.prototype.validate = function() {
    this.former.traverse_nodes(this.node, (function(_this) {
      return function(node) {
        return _this.validate_value(node);
      };
    })(this));
    if (this._invalids.length) {
      this.trigger(pi.FormEvent.Invalid, this._invalids);
      return false;
    } else {
      return true;
    }
  };

  Form.prototype.validate_value = function(node) {
    var nod;
    if ((nod = node._nod) instanceof pi.BaseInput) {
      return this.validate_nod(nod);
    }
  };

  Form.prototype.validate_nod = function(nod) {
    var flag, type, types, _i, _len, _ref;
    if ((types = nod.data('validates'))) {
      flag = true;
      _ref = types.split(" ");
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        type = _ref[_i];
        if (!Validator.validate(type, nod, this)) {
          nod.addClass(pi.klass.INVALID);
          flag = false;
          break;
        }
      }
      if (flag) {
        nod.removeClass(pi.klass.INVALID);
        if (nod.__invalid__) {
          this._invalids.splice(this._invalids.indexOf(nod.name()), 1);
          delete nod.__invalid__;
        }
        return true;
      } else {
        if (nod.__invalid__ == null) {
          this._invalids.push(nod.name());
        }
        nod.__invalid__ = true;
        return false;
      }
    } else {
      return true;
    }
  };

  Form.prototype.clear_value = function(node) {
    var nod;
    if ((nod = node._nod) instanceof pi.BaseInput) {
      return nod.clear();
    } else if (utils.is_input(node)) {
      return this.former._clear_nod(node);
    }
  };

  Form.prototype.update_value = function(name, val, silent) {
    if (silent == null) {
      silent = false;
    }
    if (!name) {
      return;
    }
    name = this.former.transform_name(name);
    val = this.former.transform_value(val);
    if (_array_name(name) === true) {
      return;
    }
    utils.obj.set_path(this._value, name, val);
    if (!silent) {
      return this.trigger(pi.FormEvent.Update, this._value);
    }
  };

  return Form;

})(pi.Base);



},{"../core":34,"./base/validator":11,"./events/input_events":13}],17:[function(require,module,exports){
'use strict';
var pi, utils,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
  __hasProp = {}.hasOwnProperty;

pi = require('../../core');

utils = pi.utils;

pi.Guesser = (function() {
  function Guesser() {}

  Guesser.klasses = [];

  Guesser.klass_reg = null;

  Guesser.klass_to_component = {};

  Guesser.tag_to_component = {};

  Guesser.specials = {};

  Guesser.compile_klass_reg = function() {
    if (!this.klasses.length) {
      return this.klass_reg = null;
    } else {
      return this.klass_reg = new RegExp("(" + this.klasses.map(function(klass) {
        return "(\\b" + (utils.escapeRegexp(klass)) + "\\b)";
      }).join("|") + ")", "g");
    }
  };

  Guesser.rules_for = function(component_name, klasses, tags, fun) {
    var klass, tag, _base, _i, _j, _len, _len1;
    if (klasses == null) {
      klasses = [];
    }
    if (tags == null) {
      tags = [];
    }
    if (klasses.length) {
      for (_i = 0, _len = klasses.length; _i < _len; _i++) {
        klass = klasses[_i];
        this.klass_to_component[klass] = component_name;
        this.klasses.push(klass);
      }
      this.compile_klass_reg();
    }
    if (tags.length) {
      for (_j = 0, _len1 = tags.length; _j < _len1; _j++) {
        tag = tags[_j];
        ((_base = this.tag_to_component)[tag] || (_base[tag] = [])).push(component_name);
      }
    }
    if (typeof fun === 'function') {
      return this.specials[component_name] = fun;
    }
  };

  Guesser.find = function(nod) {
    var el, m, match, matches, resolver, tag, tmatches, _i, _j, _len, _len1, _match, _ref, _ref1;
    matches = [];
    if (this.klass_reg && (_match = nod.node.className.match(this.klass_reg))) {
      matches = utils.arr.uniq(_match);
      if (matches.length === 1) {
        return this.klass_to_component[matches[0]];
      }
    }
    matches = matches.map((function(_this) {
      return function(klass) {
        return _this.klass_to_component[klass];
      };
    })(this));
    tag = nod.node.nodeName.toLowerCase();
    if (tag === 'input') {
      tag += "[" + nod.node.type + "]";
    }
    if (this.tag_to_component[tag] != null) {
      tmatches = [];
      if (matches.length) {
        _ref = this.tag_to_component[tag];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          el = _ref[_i];
          if ((__indexOf.call(matches, el) >= 0)) {
            tmatches.push(el);
          }
        }
      } else {
        tmatches = this.tag_to_component[tag];
      }
      tmatches = utils.arr.uniq(tmatches);
      if (tmatches.length === 1) {
        return tmatches[0];
      } else {
        matches = tmatches;
      }
    }
    if (matches.length) {
      for (_j = 0, _len1 = matches.length; _j < _len1; _j++) {
        m = matches[_j];
        if ((this.specials[m] != null) && this.specials[m].call(null, nod)) {
          return m;
        }
      }
      return matches[matches.length - 1];
    } else {
      _ref1 = this.specials;
      for (match in _ref1) {
        if (!__hasProp.call(_ref1, match)) continue;
        resolver = _ref1[match];
        if (resolver.call(null, nod)) {
          return match;
        }
      }
    }
    return 'base';
  };

  return Guesser;

})();



},{"../../core":34}],18:[function(require,module,exports){
'use strict';
require('./app');

require('./guess/guesser');

require('./events');

require('./base/index');

require('./form');

require('../plugins/index');

require('./renderers');



},{"../plugins/index":57,"./app":1,"./base/index":5,"./events":12,"./form":16,"./guess/guesser":17,"./renderers":20}],19:[function(require,module,exports){
'use strict';
var pi, utils;

pi = require('../../core');

utils = pi.utils;

pi.Renderers = {};

pi.Renderers.Base = (function() {
  function Base() {}

  Base.prototype.render = function(nod, piecified, host) {
    if (!(nod instanceof pi.Nod)) {
      return;
    }
    return this._render(nod, nod.data(), piecified, host);
  };

  Base.prototype._render = function(nod, data, piecified, host) {
    if (piecified == null) {
      piecified = true;
    }
    if (!(nod instanceof pi.Base)) {
      if (piecified) {
        nod = nod.piecify(host);
      }
    }
    nod.record = data;
    return nod;
  };

  return Base;

})();



},{"../../core":34}],20:[function(require,module,exports){
'use strict';
require('./base');

require('./jst');

require('./mustache');



},{"./base":19,"./jst":21,"./mustache":22}],21:[function(require,module,exports){
'use strict';
var pi, utils,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

pi = require('../../core');

require('./base');

utils = pi.utils;

pi.Renderers.Jst = (function(_super) {
  __extends(Jst, _super);

  function Jst(template) {
    this.templater = JST[template];
  }

  Jst.prototype.render = function(data, piecified, host) {
    var nod;
    if (data instanceof pi.Nod) {
      return Jst.__super__.render.apply(this, arguments);
    } else {
      nod = pi.Nod.create(this.templater(data));
      return this._render(nod, data, piecified, host);
    }
  };

  return Jst;

})(pi.Renderers.Base);



},{"../../core":34,"./base":19}],22:[function(require,module,exports){
'use strict';
var pi, utils,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

pi = require('../../core');

require('./base');

utils = pi.utils;

pi.Renderers.Mustache = (function(_super) {
  __extends(Mustache, _super);

  function Mustache(template) {
    var tpl_nod;
    if (window.Mustache == null) {
      throw Error('Mustache not found');
    }
    tpl_nod = $("#" + template);
    if (tpl_nod == null) {
      throw Error("Template #" + template + " not found!");
    }
    this.template = tpl_nod.html().trim();
    window.Mustache.parse(this.template);
  }

  Mustache.prototype.render = function(data, piecified, host) {
    var nod;
    if (data instanceof pi.Nod) {
      return Mustache.__super__.render.apply(this, arguments);
    } else {
      nod = pi.Nod.create(window.Mustache.render(this.template, data));
      return this._render(nod, data, piecified, host);
    }
  };

  return Mustache;

})(pi.Renderers.Base);



},{"../../core":34,"./base":19}],23:[function(require,module,exports){
'use strict';
var app, pi, utils,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

pi = require('../core');

utils = pi.utils;

pi.controllers = {};

app = pi.app;

pi.controllers.Base = (function(_super) {
  __extends(Base, _super);

  Base.prototype.id = 'base';

  function Base(view) {
    this.view = view;
    this._initialized = false;
  }

  Base.prototype.initialize = function() {
    return this._initialized = true;
  };

  Base.prototype.load = function(context_data) {
    if (!this._initialized) {
      this.initialize();
    }
    this.view.loaded(context_data.data);
  };

  Base.prototype.reload = function(context_data) {
    this.view.reloaded(context_data.data);
  };

  Base.prototype.switched = function() {
    this.view.switched();
  };

  Base.prototype.unload = function() {
    this.view.unloaded();
  };

  Base.prototype.exit = function(data) {
    return app.page.switch_back(data);
  };

  Base.prototype["switch"] = function(to, data) {
    return app.page.switch_context(this.id, to, data);
  };

  return Base;

})(pi.Core);



},{"../core":34}],24:[function(require,module,exports){
'use strict';
require('./base');

require('./page');



},{"./base":23,"./page":25}],25:[function(require,module,exports){
'use strict';
var History, pi, utils,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

pi = require('../core');

require('./base');

utils = pi.utils;

History = require('../core/utils/history');

pi.controllers.Page = (function(_super) {
  __extends(Page, _super);

  function Page() {
    this._contexts = {};
    this.context_id = null;
    this._history = new History();
  }

  Page.prototype.add_context = function(controller, main) {
    this._contexts[controller.id] = controller;
    if (main) {
      return this._main_context_id = controller.id;
    }
  };

  Page.prototype.initialize = function() {
    return this.switch_context(null, this._main_context_id);
  };

  Page.prototype.wrap_context_data = function(context, data) {
    var res;
    res = {};
    if (context != null) {
      res.context = context.id;
    }
    if ((context != null ? context.data_wrap : void 0) != null) {
      res.data = {};
      res.data[context.data_wrap] = data;
    } else {
      res.data = data;
    }
    return res;
  };

  Page.prototype.switch_context = function(from, to, data, exit) {
    var new_context, promise;
    if (data == null) {
      data = {};
    }
    if (exit == null) {
      exit = false;
    }
    if (from && from !== this.context_id) {
      utils.warning("trying to switch from non-active context");
      return utils.promise.rejected_promise();
    }
    if (!to || (this.context_id === to)) {
      return;
    }
    if (!this._contexts[to]) {
      utils.warning("undefined context: " + to);
      return utils.promise.rejected_promise();
    }
    utils.info("context switch: " + from + " -> " + to);
    new_context = this._contexts[to];
    promise = !exit && (new_context.preload != null) && (typeof new_context.preload === 'function') ? new_context.preload() : utils.promise.resolved_promise();
    return promise.then((function(_this) {
      return function() {
        if (_this.context != null) {
          if (exit) {
            _this.context.unload();
          } else {
            _this.context.switched();
          }
        }
        data = _this.wrap_context_data(_this.context, data);
        if ((from != null) && !exit) {
          _this._history.push(from);
        }
        _this.context = _this._contexts[to];
        _this.context_id = to;
        if (exit) {
          return _this.context.reload(data);
        } else {
          return _this.context.load(data);
        }
      };
    })(this));
  };

  Page.prototype.switch_to = function(to, data) {
    return this.switch_context(this.context_id, to, data);
  };

  Page.prototype.switch_back = function(data) {
    if (this.context != null) {
      return this.switch_context(this.context_id, this._history.pop(), data, true);
    } else {
      return utils.promise.rejected_promise();
    }
  };

  Page.prototype.dispose = function() {
    this.context = void 0;
    this.context_id = void 0;
    this._contexts = {};
    return this._history.clear();
  };

  return Page;

})(pi.Core);

pi.app.page = new pi.controllers.Page();

pi.Compiler.modifiers.push(function(str) {
  if (str.slice(0, 2) === '@@') {
    str = "@app.page.context." + str.slice(2);
  }
  return str;
});



},{"../core":34,"../core/utils/history":41,"./base":23}],26:[function(require,module,exports){
'use strict';
var pi;

pi = require('./pi');

pi.config = {};



},{"./pi":36}],27:[function(require,module,exports){
'use strict';
var pi, utils,
  __slice = [].slice;

pi = require('./pi');

require('./utils');

utils = pi.utils;

pi.Core = (function() {
  var _after, _before;

  Core.include = function() {
    var mixin, mixins, _i, _len, _results;
    mixins = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    _results = [];
    for (_i = 0, _len = mixins.length; _i < _len; _i++) {
      mixin = mixins[_i];
      utils.extend(this.prototype, mixin.prototype, true, ['constructor']);
      _results.push(mixin.included(this));
    }
    return _results;
  };

  Core.extend = function() {
    var mixin, mixins, _i, _len, _results;
    mixins = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    _results = [];
    for (_i = 0, _len = mixins.length; _i < _len; _i++) {
      mixin = mixins[_i];
      utils.extend(this, mixin, true);
      _results.push(mixin.extended(this));
    }
    return _results;
  };

  Core.alias = function(from, to) {
    this.prototype[from] = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return this[to].apply(this, args);
    };
  };

  Core.class_alias = function(from, to) {
    this[from] = this[to];
  };

  Core.included = function() {
    return true;
  };

  Core.extended = function() {
    return true;
  };

  Core.register_callback = function(method, options) {
    var callback_name, _fn, _i, _len, _ref, _when;
    if (options == null) {
      options = {};
    }
    callback_name = options.as || method;
    _ref = ["before", "after"];
    _fn = (function(_this) {
      return function(_when) {
        return _this["" + _when + "_" + callback_name] = function(callback) {
          var _base, _name;
          if (this.prototype["_" + _when + "_" + callback_name] && !this.prototype.hasOwnProperty("_" + _when + "_" + callback_name)) {
            this.prototype["_" + _when + "_" + callback_name] = this.prototype["_" + _when + "_" + callback_name].slice();
          }
          return ((_base = this.prototype)[_name = "_" + _when + "_" + callback_name] || (_base[_name] = [])).push(callback);
        };
      };
    })(this);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      _when = _ref[_i];
      _fn(_when);
    }
    this.prototype["__" + method] = function() {
      var args, res;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      this.run_callbacks("before_" + callback_name, args);
      res = this.constructor.prototype[method].apply(this, args);
      this.run_callbacks("after_" + callback_name, args);
      return res;
    };
    return (this.callbacked || (this.callbacked = [])).push(method);
  };

  _before = function(name) {
    if (this["__h__" + name] != null) {
      return this["__h__" + name];
    }
  };

  _after = function(name, res) {
    return this["__h__" + name] = res;
  };

  Core.event_handler = function(name, options) {
    if (options == null) {
      options = {};
    }
    if (typeof this.prototype[name] !== 'function') {
      return utils.error("undefined handler", this, name);
    }
    this.prototype[name] = utils.func.unwrap(this.prototype[name], options);
    return this.prototype[name] = utils.func.wrap(this.prototype[name], utils.curry(_before, name), utils.curry(_after, name), {
      break_if_value: true
    });
  };

  function Core() {
    var method, _fn, _i, _len, _ref;
    _ref = this.constructor.callbacked || [];
    _fn = (function(_this) {
      return function(method) {
        return _this[method] = _this["__" + method];
      };
    })(this);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      method = _ref[_i];
      _fn(method);
    }
  }

  Core.prototype.run_callbacks = function(type, args) {
    var callback, _i, _len, _ref, _results;
    _ref = this["_" + type] || [];
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      callback = _ref[_i];
      _results.push(callback.apply(this, args));
    }
    return _results;
  };

  Core.prototype.delegate_to = function() {
    var method, methods, to, _fn, _i, _len;
    to = arguments[0], methods = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    to = typeof to === 'string' ? this[to] : to;
    _fn = (function(_this) {
      return function(method) {
        return _this[method] = function() {
          var args;
          args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
          return to[method].apply(to, args);
        };
      };
    })(this);
    for (_i = 0, _len = methods.length; _i < _len; _i++) {
      method = methods[_i];
      _fn(method);
    }
  };

  return Core;

})();



},{"./pi":36,"./utils":42}],28:[function(require,module,exports){
'use strict';
var pi;

pi = require('../pi');

require('./nod_events');

pi.NodEvent.register_alias('mousewheel', 'DOMMouseScroll');



},{"../pi":36,"./nod_events":31}],29:[function(require,module,exports){
'use strict';
var pi, utils, _true, _types,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

pi = require('../pi');

require('../utils/index');

require('../core');

utils = pi.utils;

pi.Event = (function(_super) {
  __extends(Event, _super);

  function Event(event, target, bubbles) {
    this.target = target;
    if (bubbles == null) {
      bubbles = true;
    }
    if ((event != null) && typeof event === "object") {
      utils.extend(this, event);
    } else {
      this.type = event;
    }
    this.bubbles = bubbles;
    this.canceled = false;
    this.captured = false;
  }

  Event.prototype.cancel = function() {
    return this.canceled = true;
  };

  return Event;

})(pi.Core);

_true = function() {
  return true;
};

pi.EventListener = (function(_super) {
  __extends(EventListener, _super);

  function EventListener(type, handler, context, disposable, conditions) {
    this.type = type;
    this.handler = handler;
    this.context = context != null ? context : null;
    this.disposable = disposable != null ? disposable : false;
    this.conditions = conditions;
    EventListener.__super__.constructor.apply(this, arguments);
    if (this.handler._uid == null) {
      this.handler._uid = "fun" + utils.uid();
    }
    this.uid = "" + this.type + ":" + this.handler._uid;
    if (typeof this.conditions !== 'function') {
      this.conditions = _true;
    }
    if (this.context != null) {
      if (this.context._uid == null) {
        this.context._uid = "obj" + utils.uid();
      }
      this.uid += ":" + this.context._uid;
    }
  }

  EventListener.prototype.dispatch = function(event) {
    if (this.disposed || !this.conditions(event)) {
      return;
    }
    if (this.handler.call(this.context, event) !== false) {
      event.captured = true;
    }
    if (this.disposable) {
      return this.dispose();
    }
  };

  EventListener.prototype.dispose = function() {
    this.handler = this.context = this.conditions = null;
    return this.disposed = true;
  };

  return EventListener;

})(pi.Core);

_types = function(types) {
  if (typeof types === 'string') {
    return types.split(/\,\s*/);
  } else if (Array.isArray(types)) {
    return types;
  } else {
    return [null];
  }
};

pi.EventDispatcher = (function(_super) {
  __extends(EventDispatcher, _super);

  EventDispatcher.prototype.listeners = '';

  EventDispatcher.prototype.listeners_by_key = '';

  function EventDispatcher() {
    EventDispatcher.__super__.constructor.apply(this, arguments);
    this.listeners = {};
    this.listeners_by_key = {};
  }

  EventDispatcher.prototype.on = function(types, callback, context, conditions) {
    var type, _i, _len, _ref, _results;
    _ref = _types(types);
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      type = _ref[_i];
      _results.push(this.add_listener(new pi.EventListener(type, callback, context, false, conditions)));
    }
    return _results;
  };

  EventDispatcher.prototype.one = function(type, callback, context, conditions) {
    return this.add_listener(new pi.EventListener(type, callback, context, true, conditions));
  };

  EventDispatcher.prototype.off = function(types, callback, context, conditions) {
    var type, _i, _len, _ref, _results;
    _ref = _types(types);
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      type = _ref[_i];
      _results.push(this.remove_listener(type, callback, context, conditions));
    }
    return _results;
  };

  EventDispatcher.prototype.trigger = function(event, data, bubbles) {
    var listener, _i, _len, _ref;
    if (bubbles == null) {
      bubbles = true;
    }
    if (!(event instanceof pi.Event)) {
      event = new pi.Event(event, this, bubbles);
    }
    if (data != null) {
      event.data = data;
    }
    event.currentTarget = this;
    if (this.listeners[event.type] != null) {
      utils.debug_verbose("Event: " + event.type, event);
      _ref = this.listeners[event.type];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        listener = _ref[_i];
        listener.dispatch(event);
        if (event.canceled === true) {
          break;
        }
      }
      this.remove_disposed_listeners();
    }
    if (event.captured !== true) {
      if (event.bubbles) {
        this.bubble_event(event);
      }
    }
  };

  EventDispatcher.prototype.bubble_event = function(event) {};

  EventDispatcher.prototype.add_listener = function(listener) {
    var _base, _name;
    (_base = this.listeners)[_name = listener.type] || (_base[_name] = []);
    this.listeners[listener.type].push(listener);
    return this.listeners_by_key[listener.uid] = listener;
  };

  EventDispatcher.prototype.remove_listener = function(type, callback, context, conditions) {
    var listener, uid, _i, _len, _ref;
    if (context == null) {
      context = null;
    }
    if (conditions == null) {
      conditions = null;
    }
    if (type == null) {
      return this.remove_all();
    }
    if (this.listeners[type] == null) {
      return;
    }
    if (callback == null) {
      _ref = this.listeners[type];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        listener = _ref[_i];
        listener.dispose();
      }
      this.remove_type(type);
      this.remove_disposed_listeners();
      return;
    }
    uid = "" + type + ":" + callback._uid;
    if (context != null) {
      uid += ":" + context._uid;
    }
    listener = this.listeners_by_key[uid];
    if (listener != null) {
      delete this.listeners_by_key[uid];
      this.remove_listener_from_list(type, listener);
    }
  };

  EventDispatcher.prototype.remove_listener_from_list = function(type, listener) {
    if ((this.listeners[type] != null) && this.listeners[type].indexOf(listener) > -1) {
      this.listeners[type] = this.listeners[type].filter(function(item) {
        return item !== listener;
      });
      if (!this.listeners[type].length) {
        return this.remove_type(type);
      }
    }
  };

  EventDispatcher.prototype.remove_disposed_listeners = function() {
    var key, listener, _ref, _results;
    _ref = this.listeners_by_key;
    _results = [];
    for (key in _ref) {
      listener = _ref[key];
      if (listener.disposed) {
        this.remove_listener_from_list(listener.type, listener);
        _results.push(delete this.listeners_by_key[key]);
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  EventDispatcher.prototype.remove_type = function(type) {
    return delete this.listeners[type];
  };

  EventDispatcher.prototype.remove_all = function() {
    this.listeners = {};
    return this.listeners_by_key = {};
  };

  return EventDispatcher;

})(pi.Core);



},{"../core":27,"../pi":36,"../utils/index":42}],30:[function(require,module,exports){
'use strict';
require('./events');

require('./nod_events');

require('./aliases');

require('./resize_delegate');



},{"./aliases":28,"./events":29,"./nod_events":31,"./resize_delegate":32}],31:[function(require,module,exports){
'use strict';
var NodEvent, pi, utils, _key_regexp, _mouse_regexp, _prepare_event, _selector, _selector_regexp,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

pi = require('../pi');

require('../utils');

require('./events');

utils = pi.utils;

pi.NodEvent = (function(_super) {
  __extends(NodEvent, _super);

  NodEvent.aliases = {};

  NodEvent.reversed_aliases = {};

  NodEvent.delegates = {};

  NodEvent.add = (function() {
    if (typeof Element.prototype.addEventListener === "undefined") {
      return function(nod, event, handler) {
        return nod.attachEvent("on" + event, handler);
      };
    } else {
      return function(nod, event, handler) {
        return nod.addEventListener(event, handler);
      };
    }
  })();

  NodEvent.remove = (function() {
    if (typeof Element.prototype.removeEventListener === "undefined") {
      return function(nod, event, handler) {
        return nod.detachEvent("on" + event, handler);
      };
    } else {
      return function(nod, event, handler) {
        return nod.removeEventListener(event, handler);
      };
    }
  })();

  NodEvent.register_delegate = function(type, delegate) {
    return this.delegates[type] = delegate;
  };

  NodEvent.has_delegate = function(type) {
    return !!this.delegates[type];
  };

  NodEvent.register_alias = function(from, to) {
    this.aliases[from] = to;
    return this.reversed_aliases[to] = from;
  };

  NodEvent.has_alias = function(type) {
    return !!this.aliases[type];
  };

  NodEvent.is_aliased = function(type) {
    return !!this.reversed_aliases[type];
  };

  function NodEvent(event) {
    this.event = event || window.event;
    this.origTarget = this.event.target || this.event.srcElement;
    this.target = pi.Nod.create(this.origTarget);
    this.type = this.constructor.is_aliased(event.type) ? this.constructor.reversed_aliases[event.type] : event.type;
    this.ctrlKey = this.event.ctrlKey;
    this.shiftKey = this.event.shiftKey;
    this.altKey = this.event.altKey;
    this.metaKey = this.event.metaKey;
    this.detail = this.event.detail;
    this.bubbles = this.event.bubbles;
  }

  NodEvent.prototype.stopPropagation = function() {
    if (this.event.stopPropagation) {
      return this.event.stopPropagation();
    } else {
      return this.event.cancelBubble = true;
    }
  };

  NodEvent.prototype.stopImmediatePropagation = function() {
    if (this.event.stopImmediatePropagation) {
      return this.event.stopImmediatePropagation();
    } else {
      this.event.cancelBubble = true;
      return this.event.cancel = true;
    }
  };

  NodEvent.prototype.preventDefault = function() {
    if (this.event.preventDefault) {
      return this.event.preventDefault();
    } else {
      return this.event.returnValue = false;
    }
  };

  NodEvent.prototype.cancel = function() {
    this.stopImmediatePropagation();
    this.preventDefault();
    return NodEvent.__super__.cancel.apply(this, arguments);
  };

  return NodEvent;

})(pi.Event);

NodEvent = pi.NodEvent;

_mouse_regexp = /(click|mouse|contextmenu)/i;

_key_regexp = /(keyup|keydown|keypress)/i;

pi.MouseEvent = (function(_super) {
  __extends(MouseEvent, _super);

  function MouseEvent() {
    MouseEvent.__super__.constructor.apply(this, arguments);
    this.button = this.event.button;
    if (this.pageX == null) {
      this.pageX = this.event.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;
      this.pageY = this.event.clientY + document.body.scrollTop + document.documentElement.scrollTop;
    }
    if (this.offsetX == null) {
      this.offsetX = this.event.layerX - this.origTarget.offsetLeft;
      this.offsetY = this.event.layerY - this.origTarget.offsetTop;
    }
    this.wheelDelta = this.event.wheelDelta;
    if (this.wheelDelta == null) {
      this.wheelDelta = -this.event.detail * 40;
    }
  }

  return MouseEvent;

})(NodEvent);

pi.KeyEvent = (function(_super) {
  __extends(KeyEvent, _super);

  function KeyEvent() {
    KeyEvent.__super__.constructor.apply(this, arguments);
    this.keyCode = this.event.keyCode || this.event.which;
    this.charCode = this.event.charCode;
  }

  return KeyEvent;

})(NodEvent);

_prepare_event = function(e) {
  if (_mouse_regexp.test(e.type)) {
    return new pi.MouseEvent(e);
  } else if (_key_regexp.test(e.type)) {
    return new pi.KeyEvent(e);
  } else {
    return new NodEvent(e);
  }
};

_selector_regexp = /[\.#]/;

_selector = function(s, parent) {
  if (!_selector_regexp.test(s)) {
    return function(e) {
      return e.target.node.matches(s);
    };
  } else {
    return function(e) {
      var node;
      parent || (parent = document);
      node = e.target.node;
      if (node.matches(s)) {
        return true;
      }
      if (node === parent) {
        return false;
      }
      while ((node = node.parentNode) && node !== parent) {
        if (node.matches(s)) {
          return (e.target = pi.Nod.create(node));
        }
      }
    };
  }
};

pi.NodEventDispatcher = (function(_super) {
  __extends(NodEventDispatcher, _super);

  function NodEventDispatcher() {
    NodEventDispatcher.__super__.constructor.apply(this, arguments);
    this.native_event_listener = (function(_this) {
      return function(event) {
        return _this.trigger(_prepare_event(event));
      };
    })(this);
  }

  NodEventDispatcher.prototype.listen = function(selector, event, callback, context) {
    return this.on(event, callback, context, _selector(selector, this.node));
  };

  NodEventDispatcher.prototype.add_native_listener = function(type) {
    if (NodEvent.has_delegate(type)) {
      return NodEvent.delegates[type].add(this, this.native_event_listener);
    } else {
      return NodEvent.add(this.node, type, this.native_event_listener);
    }
  };

  NodEventDispatcher.prototype.remove_native_listener = function(type) {
    if (NodEvent.has_delegate(type)) {
      return NodEvent.delegates[type].remove(this);
    } else {
      return NodEvent.remove(this.node, type, this.native_event_listener);
    }
  };

  NodEventDispatcher.prototype.add_listener = function(listener) {
    if (!this.listeners[listener.type]) {
      this.add_native_listener(listener.type);
      if (NodEvent.has_alias(listener.type)) {
        this.add_native_listener(NodEvent.aliases[listener.type]);
      }
    }
    return NodEventDispatcher.__super__.add_listener.apply(this, arguments);
  };

  NodEventDispatcher.prototype.remove_type = function(type) {
    this.remove_native_listener(type);
    if (NodEvent.has_alias(type)) {
      this.remove_native_listener(NodEvent.aliases[type]);
    }
    return NodEventDispatcher.__super__.remove_type.apply(this, arguments);
  };

  NodEventDispatcher.prototype.remove_all = function() {
    var list, type, _fn, _ref;
    _ref = this.listeners;
    _fn = (function(_this) {
      return function() {
        _this.remove_native_listener(type);
        if (NodEvent.has_alias(type)) {
          return _this.remove_native_listener(NodEvent.aliases[type]);
        }
      };
    })(this);
    for (type in _ref) {
      if (!__hasProp.call(_ref, type)) continue;
      list = _ref[type];
      _fn();
    }
    return NodEventDispatcher.__super__.remove_all.apply(this, arguments);
  };

  return NodEventDispatcher;

})(pi.EventDispatcher);



},{"../pi":36,"../utils":42,"./events":29}],32:[function(require,module,exports){
'use strict';
var pi, utils,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

pi = require('../pi');

require('../utils');

require('./nod_events');

utils = pi.utils;

pi.NodEvent.ResizeListener = (function(_super) {
  __extends(ResizeListener, _super);

  function ResizeListener(nod, handler) {
    var _filter;
    this.nod = nod;
    this.handler = handler;
    this._w = this.nod.width();
    this._h = this.nod.height();
    _filter = (function(_this) {
      return function(e) {
        if (_this._w !== e.width || _this._h !== e.height) {
          _this._w = e.width;
          _this._h = e.height;
          return true;
        } else {
          return false;
        }
      };
    })(this);
    ResizeListener.__super__.constructor.call(this, 'resize', this.handler, this.nod, false, _filter);
  }

  return ResizeListener;

})(pi.EventListener);

pi.NodEvent.ResizeDelegate = (function(_super) {
  __extends(ResizeDelegate, _super);

  function ResizeDelegate() {
    this.listeners = [];
  }

  ResizeDelegate.prototype.add = function(nod, callback) {
    this.listeners.push(new pi.NodEvent.ResizeListener(nod, callback));
    if (this.listeners.length === 1) {
      return this.listen();
    }
  };

  ResizeDelegate.prototype.remove = function(nod) {
    var flag, i, listener, _i, _len, _ref;
    flag = false;
    _ref = this.listeners;
    for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
      listener = _ref[i];
      if (listener.nod === nod) {
        flag = true;
        break;
      }
    }
    if (flag === true) {
      return this.listeners.splice(i, 1);
    }
  };

  ResizeDelegate.prototype.listen = function() {
    return pi.NodEvent.add(pi.Nod.win.node, 'resize', this.resize_listener());
  };

  ResizeDelegate.prototype.off = function() {
    return pi.NodEvent.remove(pi.Nod.win.node, 'resize', this.resize_listener());
  };

  ResizeDelegate.prototype.resize_listener = function(e) {
    var listener, _i, _len, _ref, _results;
    _ref = this.listeners;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      listener = _ref[_i];
      _results.push(listener.dispatch(this._create_event(listener)));
    }
    return _results;
  };

  ResizeDelegate.event_handler('resize_listener', {
    throttle: 300
  });

  ResizeDelegate.prototype._create_event = function(listener) {
    var nod;
    nod = listener.nod;
    return {
      type: 'resize',
      target: nod,
      width: nod.width(),
      height: nod.height()
    };
  };

  return ResizeDelegate;

})(pi.Core);

pi.NodEvent.register_delegate('resize', new pi.NodEvent.ResizeDelegate());



},{"../pi":36,"../utils":42,"./nod_events":31}],33:[function(require,module,exports){
'use strict';
var pi, utils,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

pi = require('../pi');

utils = pi.utils;

pi.Former = (function() {
  function Former(nod, options) {
    this.nod = nod;
    this.options = options != null ? options : {};
    if (this.options.rails === true) {
      this.options.name_transform = this._rails_name_transform;
    }
    if (this.options.serialize === true) {
      this.options.parse_value = utils.serialize;
    }
  }

  Former.parse = function(nod, options) {
    return (new pi.Former(nod, options)).parse();
  };

  Former.fill = function(nod, options) {
    return (new pi.Former(nod, options)).fill();
  };

  Former.clear = function(nod, options) {
    return (new pi.Former(nod, options)).clear();
  };

  Former.prototype.parse = function() {
    return this.process_name_values(this.collect_name_values());
  };

  Former.prototype.fill = function(data) {
    return this.traverse_nodes(this.nod, (function(_this) {
      return function(nod) {
        return _this._fill_nod(nod, data);
      };
    })(this));
  };

  Former.prototype.clear = function() {
    return this.traverse_nodes(this.nod, (function(_this) {
      return function(nod) {
        return _this._clear_nod(nod);
      };
    })(this));
  };

  Former.prototype.process_name_values = function(name_values) {
    var item, _arrays, _fn, _i, _len, _result;
    _result = {};
    _arrays = {};
    _fn = (function(_this) {
      return function(item) {
        var i, len, name, name_part, value, _arr_fullname, _current, _j, _len1, _name_parts, _results;
        name = item.name, value = item.value;
        if (_this.options.skip_empty && (value === '' || value === null)) {
          return;
        }
        _arr_fullname = '';
        _current = _result;
        name = _this.transform_name(name, false);
        value = _this.transform_value(value);
        _name_parts = name.split(".");
        len = _name_parts.length;
        _results = [];
        for (i = _j = 0, _len1 = _name_parts.length; _j < _len1; i = ++_j) {
          name_part = _name_parts[i];
          _results.push((function(name_part) {
            var _arr_len, _arr_name, _array_item, _next_field;
            if (name_part.indexOf('[]') > -1) {
              _arr_name = name_part.substr(0, name_part.indexOf('['));
              _arr_fullname += _arr_name;
              _current[_arr_name] || (_current[_arr_name] = []);
              if (i === (len - 1)) {
                return _current[_arr_name].push(value);
              } else {
                _next_field = _name_parts[i + 1];
                _arrays[_arr_fullname] || (_arrays[_arr_fullname] = []);
                _arr_len = _arrays[_arr_fullname].length;
                if (_current[_arr_name].length > 0) {
                  _array_item = _current[_arr_name][_current[_arr_name].length - 1];
                }
                if (!_arr_len || ((__indexOf.call(_arrays[_arr_fullname], _next_field) >= 0) && !(_next_field.indexOf('[]') > -1 || !((_array_item[_next_field] != null) && (i + 1 === len - 1))))) {
                  _array_item = {};
                  _current[_arr_name].push(_array_item);
                  _arrays[_arr_fullname] = [];
                }
                _arrays[_arr_fullname].push(_next_field);
                return _current = _array_item;
              }
            } else {
              _arr_fullname += name_part;
              if (i < (len - 1)) {
                _current[name_part] || (_current[name_part] = {});
                return _current = _current[name_part];
              } else {
                return _current[name_part] = value;
              }
            }
          })(name_part));
        }
        return _results;
      };
    })(this);
    for (_i = 0, _len = name_values.length; _i < _len; _i++) {
      item = name_values[_i];
      _fn(item);
    }
    return _result;
  };

  Former.prototype.collect_name_values = function() {
    return this.traverse_nodes(this.nod, (function(_this) {
      return function(nod) {
        return _this._parse_nod(nod);
      };
    })(this));
  };

  Former.prototype.traverse_nodes = function(nod, callback) {
    var current, result;
    result = this._to_array(callback(nod));
    current = nod.firstChild;
    while ((current != null)) {
      if (current.nodeType === 1) {
        result = result.concat(this.traverse_nodes(current, callback));
      }
      current = current.nextSibling;
    }
    return result;
  };

  Former.prototype.transform_name = function(name, prefix) {
    if (prefix == null) {
      prefix = true;
    }
    if (this.options.fill_prefix && prefix) {
      name = name.replace(this.options.fill_prefix, '');
    }
    if (this.options.name_transform != null) {
      name = this.options.name_transform(name);
    }
    return name;
  };

  Former.prototype.transform_value = function(val) {
    if (this.options.parse_value != null) {
      return this.options.parse_value(val);
    }
    return val;
  };

  Former.prototype._to_array = function(val) {
    if (val == null) {
      return [];
    } else {
      return utils.to_a(val);
    }
  };

  Former.prototype._parse_nod = function(nod) {
    var val;
    if (this.options.disabled === false && nod.disabled) {
      return;
    }
    if (!/(input|select|textarea)/i.test(nod.nodeName)) {
      return;
    }
    if (!nod.name) {
      return;
    }
    val = this._parse_nod_value(nod);
    if (val == null) {
      return;
    }
    return {
      name: nod.name,
      value: val
    };
  };

  Former.prototype._fill_nod = function(nod, data) {
    var type, value;
    if (!/(input|select|textarea)/i.test(nod.nodeName)) {
      return;
    }
    value = this._nod_data_value(nod.name, data);
    if (value == null) {
      return;
    }
    if (nod.nodeName.toLowerCase() === 'select') {
      this._fill_select(nod, value);
    } else {
      if (typeof value === 'object') {
        return;
      }
      type = nod.type.toLowerCase();
      switch (false) {
        case !(/(radio|checkbox)/.test(type) && value):
          nod.checked = true;
          break;
        case !(/(radio|checkbox)/.test(type) && !value):
          nod.checked = false;
          break;
        default:
          nod.value = value;
      }
    }
  };

  Former.prototype._fill_select = function(nod, value) {
    var option, _i, _len, _ref, _results;
    value = value instanceof Array ? value : [value];
    value = value.map(function(val) {
      return "" + val;
    });
    _ref = nod.getElementsByTagName("option");
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      option = _ref[_i];
      _results.push((function(option) {
        var _ref1;
        return option.selected = (_ref1 = option.value, __indexOf.call(value, _ref1) >= 0);
      })(option));
    }
    return _results;
  };

  Former.prototype._clear_nod = function(nod) {
    var type;
    if (!/(input|select|textarea)/i.test(nod.nodeName)) {
      return;
    }
    if (nod.nodeName.toLowerCase() === 'select') {
      this._fill_select(nod, []);
    } else {
      type = nod.type.toLowerCase();
      switch (false) {
        case !/(radio|checkbox)/.test(type):
          nod.checked = false;
          break;
        case !(type === 'hidden' && !this.options.clear_hidden):
          true;
          break;
        default:
          nod.value = '';
      }
    }
  };

  Former.prototype._nod_data_value = function(name, data) {
    var key, _i, _len, _ref;
    if (!name) {
      return;
    }
    name = this.transform_name(name);
    if (name.indexOf('[]') > -1) {
      return;
    }
    _ref = name.split(".");
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      key = _ref[_i];
      data = data[key];
      if (data == null) {
        break;
      }
    }
    return data;
  };

  Former.prototype._parse_nod_value = function(nod) {
    var type;
    if (nod.nodeName.toLowerCase() === 'select') {
      return this._parse_select_value(nod);
    } else {
      type = nod.type.toLowerCase();
      switch (false) {
        case !(/(radio|checkbox)/.test(type) && nod.checked):
          return nod.value;
        case !(/(radio|checkbox)/.test(type) && !nod.checked):
          return null;
        case !/(button|reset|submit|image)/.test(type):
          return null;
        case !/(file)/.test(type):
          return this._parse_file_value(nod);
        default:
          return nod.value;
      }
    }
  };

  Former.prototype._parse_file_value = function(nod) {
    var _ref;
    if (!((_ref = nod.files) != null ? _ref.length : void 0)) {
      return;
    }
    if (nod.multiple) {
      return nod.files;
    } else {
      return nod.files[0];
    }
  };

  Former.prototype._parse_select_value = function(nod) {
    var multiple, option, _i, _len, _ref, _results;
    multiple = nod.multiple;
    if (!multiple) {
      return nod.value;
    }
    _ref = nod.getElementsByTagName("option");
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      option = _ref[_i];
      if (option.selected) {
        _results.push(option.value);
      }
    }
    return _results;
  };

  Former.prototype._rails_name_transform = function(name) {
    return name.replace(/\[([^\]])/ig, ".$1").replace(/([^\[])([\]]+)/ig, "$1");
  };

  return Former;

})();



},{"../pi":36}],34:[function(require,module,exports){
'use strict';
var pi;

pi = require('./pi');

require('./config');

require('./nod');

require('./former/former');

module.exports = pi;



},{"./config":26,"./former/former":33,"./nod":35,"./pi":36}],35:[function(require,module,exports){
'use strict';
var d, info, klasses, pi, utils, version, versions, _caf, _data_reg, _dataset, _fn, _fn1, _fragment, _from_dataCase, _geometry_styles, _i, _j, _len, _len1, _node, _prop_hash, _raf, _ref, _ref1,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __slice = [].slice;

pi = require('./pi');

require('./utils');

require('./events');

utils = pi.utils;

_prop_hash = function(method, callback) {
  return pi.Nod.prototype[method] = function(prop, val) {
    var k, p;
    if (typeof prop !== "object") {
      return callback.call(this, prop, val);
    }
    for (k in prop) {
      if (!__hasProp.call(prop, k)) continue;
      p = prop[k];
      callback.call(this, k, p);
    }
  };
};

_geometry_styles = function(sty) {
  var s, _fn, _i, _len;
  _fn = function() {
    var name;
    name = s;
    pi.Nod.prototype[name] = function(val) {
      if (val === void 0) {
        return this.node["offset" + (utils.capitalize(name))];
      }
      this._with_raf(name, (function(_this) {
        return function() {
          _this.node.style[name] = val + "px";
          if (name === 'width' || name === 'height') {
            return _this.trigger('resize');
          }
        };
      })(this));
      return this;
    };
  };
  for (_i = 0, _len = sty.length; _i < _len; _i++) {
    s = sty[_i];
    _fn();
  }
};

_node = function(n) {
  if (n instanceof pi.Nod) {
    return n.node;
  }
  if (typeof n === "string") {
    return _fragment(n);
  }
  return n;
};

_data_reg = /^data-\w[\w\-]*$/;

_from_dataCase = function(str) {
  var words;
  words = str.split('-');
  return words.join('_');
};

_dataset = (function() {
  if (typeof DOMStringMap === "undefined") {
    return function(node) {
      var attr, dataset, _i, _len, _ref;
      dataset = {};
      if (node.attributes != null) {
        _ref = node.attributes;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          attr = _ref[_i];
          if (_data_reg.test(attr.name)) {
            dataset[_from_dataCase(attr.name.slice(5))] = utils.serialize(attr.value);
          }
        }
      }
      return dataset;
    };
  } else {
    return function(node) {
      var dataset, key, val, _ref;
      dataset = {};
      _ref = node.dataset;
      for (key in _ref) {
        if (!__hasProp.call(_ref, key)) continue;
        val = _ref[key];
        dataset[utils.snake_case(key)] = utils.serialize(val);
      }
      return dataset;
    };
  }
})();

_fragment = function(html) {
  var f, temp;
  temp = document.createElement('div');
  temp.innerHTML = html;
  f = document.createDocumentFragment();
  while (temp.firstChild) {
    f.appendChild(temp.firstChild);
  }
  return f;
};

_raf = window.requestAnimationFrame != null ? window.requestAnimationFrame : function(callback) {
  return utils.after(0, callback);
};

_caf = window.cancelAnimationFrame != null ? window.cancelAnimationFrame : function() {
  return true;
};

pi.Nod = (function(_super) {
  __extends(Nod, _super);

  function Nod(node) {
    this.node = node;
    Nod.__super__.constructor.apply(this, arguments);
    if (this.node == null) {
      throw Error("Node is undefined!");
    }
    this._disposed = false;
    this._data = _dataset(node);
    if (this.node._nod == null) {
      this.node._nod = this;
    }
  }

  Nod.create = function(node) {
    switch (false) {
      case !!node:
        return null;
      case !(node instanceof this):
        return node;
      case !(typeof node["_nod"] !== "undefined"):
        return node._nod;
      case !utils.is_html(node):
        return this._create_html(node);
      case typeof node !== "string":
        return new this(document.createElement(node));
      default:
        return new this(node);
    }
  };

  Nod._create_html = function(html) {
    var node, temp;
    temp = _fragment(html);
    node = temp.firstChild;
    temp.removeChild(node);
    return new this(node);
  };

  Nod.prototype.find = function(selector) {
    return pi.Nod.create(this.node.querySelector(selector));
  };

  Nod.prototype.all = function(selector) {
    return this.node.querySelectorAll(selector);
  };

  Nod.prototype.each = function(selector, callback) {
    var i, node, _i, _len, _ref, _results;
    i = 0;
    _ref = this.node.querySelectorAll(selector);
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      node = _ref[_i];
      if (callback.call(null, node, i) === true) {
        break;
      }
      _results.push(i++);
    }
    return _results;
  };

  Nod.prototype.first = function(selector) {
    return this.find(selector);
  };

  Nod.prototype.last = function(selector) {
    return this.find("" + selector + ":last-child");
  };

  Nod.prototype.nth = function(selector, n) {
    return this.find("" + selector + ":nth-child(" + n + ")");
  };

  Nod.prototype.find_bf = function(selector) {
    var acc, el, nod, rest;
    rest = [];
    acc = [];
    el = this.node.firstChild;
    while (el) {
      if (el.nodeType !== 1) {
        el = el.nextSibling || rest.shift();
        continue;
      }
      if (el.matches(selector)) {
        acc.push(el);
        nod = el.querySelector(selector);
        if (nod != null) {
          rest.push(nod);
        }
      } else {
        if ((nod = el.querySelector(selector))) {
          el.nextSibling && rest.unshift(el.nextSibling);
          el = nod;
          continue;
        }
      }
      el = el.nextSibling || rest.shift();
    }
    return acc;
  };

  Nod.prototype.attrs = function(data) {
    var name, val;
    for (name in data) {
      if (!__hasProp.call(data, name)) continue;
      val = data[name];
      this.attr(name, val);
    }
    return this;
  };

  Nod.prototype.styles = function(data) {
    var name, val;
    for (name in data) {
      if (!__hasProp.call(data, name)) continue;
      val = data[name];
      this.style(name, val);
    }
    return this;
  };

  Nod.prototype.parent = function(selector) {
    var p;
    if (selector == null) {
      if (this.node.parentNode != null) {
        return pi.Nod.create(this.node.parentNode);
      } else {
        return null;
      }
    } else {
      p = this.node;
      while ((p = p.parentNode) && (p !== document)) {
        if (p.matches(selector)) {
          return pi.Nod.create(p);
        }
      }
      return null;
    }
  };

  Nod.prototype.children = function(selector) {
    var n, _i, _len, _ref, _results;
    if (selector != null) {
      _ref = this.node.children;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        n = _ref[_i];
        if (n.matches(selector)) {
          _results.push(n);
        }
      }
      return _results;
    } else {
      return this.node.children;
    }
  };

  Nod.prototype.wrap = function() {
    var klasses, wrapper;
    klasses = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    wrapper = pi.Nod.create('div');
    wrapper.addClass.apply(wrapper, klasses);
    this.node.parentNode.insertBefore(wrapper.node, this.node);
    return wrapper.append(this.node);
  };

  Nod.prototype.prepend = function(node) {
    node = _node(node);
    this.node.insertBefore(node, this.node.firstChild);
    return this;
  };

  Nod.prototype.append = function(node) {
    node = _node(node);
    this.node.appendChild(node);
    return this;
  };

  Nod.prototype.insertBefore = function(node) {
    node = _node(node);
    this.node.parentNode.insertBefore(node, this.node);
    return this;
  };

  Nod.prototype.insertAfter = function(node) {
    node = _node(node);
    this.node.parentNode.insertBefore(node, this.node.nextSibling);
    return this;
  };

  Nod.prototype.detach = function() {
    var _ref;
    if ((_ref = this.node.parentNode) != null) {
      _ref.removeChild(this.node);
    }
    return this;
  };

  Nod.prototype.detach_children = function() {
    while (this.node.children.length) {
      this.node.removeChild(this.node.children[0]);
    }
    return this;
  };

  Nod.prototype.remove_children = function() {
    while (this.node.firstChild) {
      if (this.node.firstChild._nod) {
        this.node.firstChild._nod.remove();
      } else {
        this.node.removeChild(this.node.firstChild);
      }
    }
    return this;
  };

  Nod.prototype.remove = function() {
    this.detach();
    this.remove_children();
    this.dispose();
    return null;
  };

  Nod.prototype.empty = function() {
    this.html('');
    return this;
  };

  Nod.prototype.clone = function() {
    var c, nod;
    c = document.createElement(this.node.nameNode);
    c.innerHTML = this.node.outerHTML;
    nod = new pi.Nod(c.firstChild);
    return utils.extend(nod, this, true, ['listeners', 'listeners_by_type', '__components__', 'native_event_listener', 'node']);
  };

  Nod.prototype.dispose = function() {
    var key, val;
    if (this._disposed) {
      return;
    }
    this.off();
    delete this.node._nod;
    for (key in this) {
      if (!__hasProp.call(this, key)) continue;
      val = this[key];
      delete this[key];
    }
    this._disposed = true;
  };

  Nod.prototype.html = function(val) {
    if (val != null) {
      this.node.innerHTML = val;
      return this;
    } else {
      return this.node.innerHTML;
    }
  };

  Nod.prototype.outerHTML = function(val) {
    if (val != null) {
      this.node.outerHTML = val;
      return this;
    } else {
      return this.node.outerHTML;
    }
  };

  Nod.prototype.text = function(val) {
    if (val != null) {
      this.node.textContent = val;
      return this;
    } else {
      return this.node.textContent;
    }
  };

  Nod.prototype.name = function() {
    return this.node.name || this.data('name');
  };

  Nod.prototype.value = function(val) {
    if (val != null) {
      this.node.value = val;
      return this;
    } else {
      return this.node.value;
    }
  };

  Nod.prototype.addClass = function() {
    var c, _i, _len;
    for (_i = 0, _len = arguments.length; _i < _len; _i++) {
      c = arguments[_i];
      this.node.classList.add(c);
    }
    return this;
  };

  Nod.prototype.removeClass = function() {
    var c, _i, _len;
    for (_i = 0, _len = arguments.length; _i < _len; _i++) {
      c = arguments[_i];
      this.node.classList.remove(c);
    }
    return this;
  };

  Nod.prototype.toggleClass = function(c) {
    this.node.classList.toggle(c);
    return this;
  };

  Nod.prototype.hasClass = function(c) {
    return this.node.classList.contains(c);
  };

  Nod.prototype.mergeClasses = function(nod) {
    var klass, _i, _len, _ref;
    _ref = nod.node.className.split(/\s+/);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      klass = _ref[_i];
      if (klass) {
        this.addClass(klass);
      }
    }
    return this;
  };

  Nod.prototype.x = function() {
    var node, offset;
    offset = this.node.offsetLeft;
    node = this.node;
    while ((node = node.offsetParent)) {
      offset += node.offsetLeft;
    }
    return offset;
  };

  Nod.prototype.y = function() {
    var node, offset;
    offset = this.node.offsetTop;
    node = this.node;
    while ((node = node.offsetParent)) {
      offset += node.offsetTop;
    }
    return offset;
  };

  Nod.prototype._with_raf = function(name, fun) {
    if (this["__" + name + "_rid"]) {
      _caf(this["__" + name + "_rid"]);
      delete this["__" + name + "_rid"];
    }
    return this["__" + name + "_rid"] = _raf(fun);
  };

  Nod.prototype.move = function(x, y) {
    return this._with_raf('move', (function(_this) {
      return function() {
        return _this.style({
          left: "" + x + "px",
          top: "" + y + "px"
        });
      };
    })(this));
  };

  Nod.prototype.moveX = function(x) {
    return this.left(x);
  };

  Nod.prototype.moveY = function(y) {
    return this.top(y);
  };

  Nod.prototype.scrollX = function(x) {
    return this._with_raf('scrollX', (function(_this) {
      return function() {
        return _this.node.scrollLeft = x;
      };
    })(this));
  };

  Nod.prototype.scrollY = function(y) {
    return this._with_raf('scrollY', (function(_this) {
      return function() {
        return _this.node.scrollTop = y;
      };
    })(this));
  };

  Nod.prototype.position = function() {
    return {
      x: this.x(),
      y: this.y()
    };
  };

  Nod.prototype.offset = function() {
    return {
      x: this.node.offsetLeft,
      y: this.node.offsetTop
    };
  };

  Nod.prototype.size = function(width, height) {
    if (width == null) {
      width = null;
    }
    if (height == null) {
      height = null;
    }
    if (!((width != null) && (height != null))) {
      return {
        width: this.width(),
        height: this.height()
      };
    }
    if (width == null) {
      width = this.width();
    }
    if (height == null) {
      height = this.height();
    }
    this._with_raf('size', (function(_this) {
      return function() {
        _this.node.style.width = width + "px";
        _this.node.style.height = height + "px";
        return _this.trigger('resize');
      };
    })(this));
  };

  Nod.prototype.show = function() {
    return this.node.style.display = "block";
  };

  Nod.prototype.hide = function() {
    return this.node.style.display = "none";
  };

  Nod.prototype.focus = function() {
    this.node.focus();
    return this;
  };

  Nod.prototype.blur = function() {
    this.node.blur();
    return this;
  };

  return Nod;

})(pi.NodEventDispatcher);

_prop_hash("data", function(prop, val) {
  if (prop === void 0) {
    return this._data;
  }
  prop = prop.replace("-", "_");
  if (val === null) {
    val = this._data[prop];
    delete this._data[prop];
    return val;
  }
  if (val === void 0) {
    return this._data[prop];
  } else {
    this._data[prop] = val;
    return this;
  }
});

_prop_hash("style", function(prop, val) {
  if (val === null) {
    this.node.style[prop] = null;
  } else if (val === void 0) {
    return this.node.style[prop];
  }
  return this.node.style[prop] = val;
});

_prop_hash("attr", function(prop, val) {
  if (val === null) {
    return this.node.removeAttribute(prop);
  } else if (val === void 0) {
    return this.node.getAttribute(prop);
  } else {
    return this.node.setAttribute(prop, val);
  }
});

_geometry_styles(["top", "left", "width", "height"]);

_ref = ["width", "height"];
_fn = function() {
  var prop;
  prop = "client" + (utils.capitalize(d));
  return pi.Nod.prototype[prop] = function() {
    return this.node[prop];
  };
};
for (_i = 0, _len = _ref.length; _i < _len; _i++) {
  d = _ref[_i];
  _fn();
}

_ref1 = ["top", "left", "width", "height"];
_fn1 = function() {
  var prop;
  prop = "scroll" + (utils.capitalize(d));
  return pi.Nod.prototype[prop] = function() {
    return this.node[prop];
  };
};
for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
  d = _ref1[_j];
  _fn1();
}

pi.NodRoot = (function(_super) {
  __extends(NodRoot, _super);

  NodRoot.instance = null;

  function NodRoot() {
    if (pi.NodRoot.instance) {
      throw "NodRoot is already defined!";
    }
    pi.NodRoot.instance = this;
    NodRoot.__super__.constructor.call(this, document.documentElement);
  }

  NodRoot.prototype.initialize = function() {
    var load_handler, ready_handler, _ready_state;
    _ready_state = document.attachEvent ? 'complete' : 'interactive';
    this._loaded = document.readyState === 'complete';
    if (!this._loaded) {
      this._loaded_callbacks = [];
      load_handler = (function(_this) {
        return function() {
          utils.debug('DOM loaded');
          _this._loaded = true;
          _this.fire_all();
          return pi.NodEvent.remove(window, 'load', load_handler);
        };
      })(this);
      pi.NodEvent.add(window, 'load', load_handler);
    }
    if (!this._ready) {
      if (document.addEventListener) {
        this._ready = document.readyState === _ready_state;
        if (this._ready) {
          return;
        }
        this._ready_callbacks = [];
        ready_handler = (function(_this) {
          return function() {
            utils.debug('DOM ready');
            _this._ready = true;
            _this.fire_ready();
            return document.removeEventListener('DOMContentLoaded', ready_handler);
          };
        })(this);
        return document.addEventListener('DOMContentLoaded', ready_handler);
      } else {
        this._ready = document.readyState === _ready_state;
        if (this._ready) {
          return;
        }
        this._ready_callbacks = [];
        ready_handler = (function(_this) {
          return function() {
            if (document.readyState === _ready_state) {
              utils.debug('DOM ready');
              _this._ready = true;
              _this.fire_ready();
              return document.detachEvent('onreadystatechange', ready_handler);
            }
          };
        })(this);
        return document.attachEvent('onreadystatechange', ready_handler);
      }
    }
  };

  NodRoot.prototype.ready = function(callback) {
    if (this._ready) {
      return callback.call(null);
    } else {
      return this._ready_callbacks.push(callback);
    }
  };

  NodRoot.prototype.loaded = function(callback) {
    if (this._loaded) {
      return callback.call(null);
    } else {
      return this._loaded_callbacks.push(callback);
    }
  };

  NodRoot.prototype.fire_all = function() {
    var callback;
    if (this._ready_callbacks) {
      this.fire_ready();
    }
    while (callback = this._loaded_callbacks.shift()) {
      callback.call(null);
    }
    return this._loaded_callbacks = null;
  };

  NodRoot.prototype.fire_ready = function() {
    var callback;
    while (callback = this._ready_callbacks.shift()) {
      callback.call(null);
    }
    return this._ready_callbacks = null;
  };

  NodRoot.prototype.scrollTop = function() {
    return this.node.scrollTop || document.body.scrollTop;
  };

  NodRoot.prototype.scrollLeft = function() {
    return this.node.scrollLeft || document.body.scrollLeft;
  };

  NodRoot.prototype.scrollHeight = function() {
    return this.node.scrollHeight;
  };

  NodRoot.prototype.scrollWidth = function() {
    return this.node.scrollWidth;
  };

  NodRoot.prototype.height = function() {
    return window.innerHeight || this.node.clientHeight;
  };

  NodRoot.prototype.width = function() {
    return window.innerWidth || this.node.clientWidth;
  };

  return NodRoot;

})(pi.Nod);

pi.Nod.root = new pi.NodRoot();

pi.NodWin = (function(_super) {
  __extends(NodWin, _super);

  NodWin.instance = null;

  function NodWin() {
    if (pi.NodWin.instance) {
      throw "NodWin is already defined!";
    }
    pi.NodWin.instance = this;
    this.delegate_to(pi.Nod.root, 'scrollLeft', 'scrollTop', 'scrollWidth', 'scrollHeight');
    NodWin.__super__.constructor.call(this, window);
  }

  NodWin.prototype.scrollY = function(y) {
    var x;
    x = this.scrollLeft();
    return this._with_raf('scrollY', (function(_this) {
      return function() {
        return _this.node.scrollTo(x, y);
      };
    })(this));
  };

  NodWin.prototype.scrollX = function(x) {
    var y;
    y = this.scrollTop();
    return this._with_raf('scrollX', (function(_this) {
      return function() {
        return _this.node.scrollTo(x, y);
      };
    })(this));
  };

  NodWin.prototype.width = function() {
    return this.node.innerWidth;
  };

  NodWin.prototype.height = function() {
    return this.node.innerHeight;
  };

  NodWin.prototype.x = function() {
    return 0;
  };

  NodWin.prototype.y = function() {
    return 0;
  };

  return NodWin;

})(pi.Nod);

pi.Nod.win = new pi.NodWin();

pi.Nod.body = new pi.Nod(document.body);

pi.$ = function(q) {
  if (utils.is_html(q)) {
    return pi.Nod.create(q);
  } else {
    return pi.Nod.root.find(q);
  }
};

pi["export"](pi.$, '$');

info = utils.browser.info();

klasses = [];

if (info.msie === true) {
  klasses.push('ie');
  versions = info.version.split(".");
  version = versions.length ? versions[0] : version;
  klasses.push("ie" + version);
}

if (info.mobile === true) {
  klasses.push('mobile');
}

if (info.tablet === true) {
  klasses.push('tablet');
}

if (klasses.length) {
  pi.Nod.root.addClass.apply(pi.Nod.root, klasses);
}

pi.Nod.root.initialize();



},{"./events":30,"./pi":36,"./utils":42}],36:[function(require,module,exports){
'use strict';
var pi;

pi = {};

module.exports = {};



},{}],37:[function(require,module,exports){
'use strict';
var pi, utils,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

pi = require('../pi');

require('./base');

utils = pi.utils;

utils.arr = (function() {
  function arr() {}

  arr.sort = function(arr, sort_params) {
    return arr.sort(utils.curry(utils.keys_compare, [sort_params], utils, true));
  };

  arr.sort_by = function(arr, key, order) {
    if (order == null) {
      order = 'asc';
    }
    return arr.sort(utils.curry(utils.key_compare, [key, order], utils, true));
  };

  arr.uniq = function(arr) {
    var el, res, _i, _len;
    res = [];
    for (_i = 0, _len = arr.length; _i < _len; _i++) {
      el = arr[_i];
      if ((__indexOf.call(res, el) < 0)) {
        res.push(el);
      }
    }
    return res;
  };

  arr.shuffle = function(arr) {
    var i, j, len, res, _, _i, _len;
    len = arr.length;
    res = Array(len);
    for (i = _i = 0, _len = arr.length; _i < _len; i = ++_i) {
      _ = arr[i];
      j = utils.random(0, i);
      if (i !== j) {
        res[i] = res[j];
      }
      res[j] = arr[i];
    }
    return res;
  };

  arr.sample = function(arr, size) {
    var len;
    if (size == null) {
      size = 1;
    }
    len = arr.length;
    if (size === 1) {
      return arr[utils.random(len - 1)];
    }
    return this.shuffle(arr).slice(0, +(size - 1) + 1 || 9e9);
  };

  return arr;

})();



},{"../pi":36,"./base":38}],38:[function(require,module,exports){
'use strict';
var pi, _conflicts, _uniq_id,
  __hasProp = {}.hasOwnProperty,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
  __slice = [].slice;

pi = require('../pi');

_conflicts = {};

pi["export"] = function(fun, as) {
  if (window[as] != null) {
    if (_conflicts[as] == null) {
      _conflicts[as] = window[as];
    }
  }
  return window[as] = fun;
};

pi.noconflict = function() {
  var fun, name, _results;
  _results = [];
  for (name in _conflicts) {
    if (!__hasProp.call(_conflicts, name)) continue;
    fun = _conflicts[name];
    _results.push(window[name] = fun);
  }
  return _results;
};

_uniq_id = 100;

pi.utils = (function() {
  function utils() {}

  utils.email_rxp = /\b[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}\b/i;

  utils.digital_rxp = /^[\d\s-\(\)]+$/;

  utils.html_rxp = /^\s*<[\s\S]+>\s*$/m;

  utils.esc_rxp = /[-[\]{}()*+?.,\\^$|#]/g;

  utils.clickable_rxp = /^(a|button|input|textarea)$/i;

  utils.input_rxp = /^(input|select|textarea)$/i;

  utils.notsnake_rxp = /((?:^[^A-Z]|[A-Z])[^A-Z]*)/g;

  utils.str_rxp = /(^'|'$)/g;

  utils.uid = function(pref) {
    return (pref || "") + (++_uniq_id);
  };

  utils.random = function(min, max) {
    var _ref;
    if (max == null) {
      max = null;
    }
    if (max == null) {
      _ref = [min, 0], max = _ref[0], min = _ref[1];
    }
    return min + (Math.random() * (max - min + 1)) | 0;
  };

  utils.escapeRegexp = function(str) {
    return str.replace(this.esc_rxp, "\\$&");
  };

  utils.is_digital = function(str) {
    return this.digital_rxp.test(str);
  };

  utils.is_email = function(str) {
    return this.email_rxp.test(str);
  };

  utils.is_html = function(str) {
    return this.html_rxp.test(str);
  };

  utils.is_clickable = function(node) {
    return this.clickable_rxp.test(node.nodeName);
  };

  utils.is_input = function(node) {
    return this.input_rxp.test(node.nodeName);
  };

  utils.camelCase = function(string) {
    var word;
    string = string + "";
    if (string.length) {
      return ((function() {
        var _i, _len, _ref, _results;
        _ref = string.split('_');
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          word = _ref[_i];
          _results.push(this.capitalize(word));
        }
        return _results;
      }).call(this)).join('');
    } else {
      return string;
    }
  };

  utils.snake_case = function(string) {
    var matches, word;
    string = string + "";
    if (string.length) {
      matches = string.match(this.notsnake_rxp);
      return ((function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = matches.length; _i < _len; _i++) {
          word = matches[_i];
          _results.push(word.toLowerCase());
        }
        return _results;
      })()).join('_');
    } else {
      return string;
    }
  };

  utils.capitalize = function(word) {
    return word[0].toUpperCase() + word.slice(1);
  };

  utils.serialize = function(val) {
    return val = (function() {
      switch (false) {
        case !(val == null):
          return null;
        case val !== 'null':
          return null;
        case val !== 'undefined':
          return void 0;
        case val !== 'true':
          return true;
        case val !== 'false':
          return false;
        case val !== '':
          return '';
        case !(isNaN(Number(val)) && typeof val === 'string'):
          return (val + "").replace(this.str_rxp, '');
        case !isNaN(Number(val)):
          return val;
        default:
          return Number(val);
      }
    }).call(this);
  };

  utils.key_compare = function(a, b, key, order) {
    var reverse;
    reverse = order === 'asc';
    a = this.serialize(a[key]);
    b = this.serialize(b[key]);
    if (a === b) {
      return 0;
    }
    if (!a || a < b) {
      return 1 + (-2 * reverse);
    } else {
      return -(1 + (-2 * reverse));
    }
  };

  utils.keys_compare = function(a, b, params) {
    var key, order, param, r, _fn, _i, _len;
    r = 0;
    for (_i = 0, _len = params.length; _i < _len; _i++) {
      param = params[_i];
      _fn = (function(_this) {
        return function(key, order) {
          var r_;
          r_ = _this.key_compare(a, b, key, order);
          if (r === 0) {
            return r = r_;
          }
        };
      })(this);
      for (key in param) {
        if (!__hasProp.call(param, key)) continue;
        order = param[key];
        _fn(key, order);
      }
    }
    return r;
  };

  utils.clone = function(obj, except) {
    var flags, key, newInstance;
    if (except == null) {
      except = [];
    }
    if ((obj == null) || typeof obj !== 'object') {
      return obj;
    }
    if (obj instanceof Date) {
      return new Date(obj.getTime());
    }
    if (obj instanceof RegExp) {
      flags = '';
      if (obj.global != null) {
        flags += 'g';
      }
      if (obj.ignoreCase != null) {
        flags += 'i';
      }
      if (obj.multiline != null) {
        flags += 'm';
      }
      if (obj.sticky != null) {
        flags += 'y';
      }
      return new RegExp(obj.source, flags);
    }
    if (obj instanceof Element) {
      return obj.cloneNode(true);
    }
    if (typeof obj.clone === 'function') {
      return obj.clone();
    }
    newInstance = new obj.constructor();
    for (key in obj) {
      if ((__indexOf.call(except, key) < 0)) {
        newInstance[key] = this.clone(obj[key]);
      }
    }
    return newInstance;
  };

  utils.merge = function(to, from) {
    var key, obj, prop;
    obj = this.clone(to);
    for (key in from) {
      if (!__hasProp.call(from, key)) continue;
      prop = from[key];
      obj[key] = prop;
    }
    return obj;
  };

  utils.extend = function(target, data, overwrite, except) {
    var key, prop;
    if (overwrite == null) {
      overwrite = false;
    }
    if (except == null) {
      except = [];
    }
    for (key in data) {
      if (!__hasProp.call(data, key)) continue;
      prop = data[key];
      if (((target[key] == null) || overwrite) && !(__indexOf.call(except, key) >= 0)) {
        target[key] = prop;
      }
    }
    return target;
  };

  utils.extract_to = function(data, source, param) {
    var el, key, p, vals, _fn, _i, _j, _len, _len1;
    if (source == null) {
      return;
    }
    if (Array.isArray(source)) {
      _fn = (function(_this) {
        return function(el) {
          var el_data;
          el_data = {};
          _this.extract_to(el_data, el, param);
          return data.push(el_data);
        };
      })(this);
      for (_i = 0, _len = source.length; _i < _len; _i++) {
        el = source[_i];
        _fn(el);
      }
      data;
    } else {
      if (typeof param === 'string') {
        if (source[param] != null) {
          data[param] = source[param];
        }
      } else if (Array.isArray(param)) {
        for (_j = 0, _len1 = param.length; _j < _len1; _j++) {
          p = param[_j];
          this.extract_to(data, source, p);
        }
      } else {
        for (key in param) {
          if (!__hasProp.call(param, key)) continue;
          vals = param[key];
          if (source[key] == null) {
            return;
          }
          if (Array.isArray(source[key])) {
            data[key] = [];
          } else {
            data[key] = {};
          }
          this.extract_to(data[key], source[key], vals);
        }
      }
    }
    return data;
  };

  utils.extract = function(source, param) {
    var data;
    data = {};
    this.extract_to(data, source, param);
    return data;
  };

  utils.subclass = function(parent) {
    var child, key;
    child = function() {
      return this.constructor.__super__.constructor.apply(this, arguments);
    };
    for (key in parent) {
      if (!__hasProp.call(parent, key)) continue;
      child[key] = parent[key];
    }
    child.prototype = Object.create(parent.prototype);
    child.prototype.constructor = child;
    child.__super__ = parent.prototype;
    return child;
  };

  utils.to_a = function(obj) {
    if (obj == null) {
      return [];
    }
    if (Array.isArray(obj)) {
      return obj;
    } else {
      return [obj];
    }
  };

  utils.debounce = function(period, fun, ths, throttle) {
    var _buf, _wait;
    if (throttle == null) {
      throttle = false;
    }
    _wait = false;
    _buf = null;
    return function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      if (_wait) {
        _buf = args;
        return;
      }
      (ths || {}).__debounce_id__ = pi.utils.after(period, function() {
        _wait = false;
        if (throttle && (_buf != null)) {
          fun.apply(ths, _buf);
        }
        return _buf = null;
      });
      _wait = true;
      if (_buf == null) {
        return fun.apply(ths, args);
      }
    };
  };

  utils.throttle = function(period, fun, ths) {
    return pi.utils.debounce(period, fun, ths, true);
  };

  utils.curry = function(fun, args, ths, last) {
    if (args == null) {
      args = [];
    }
    if (last == null) {
      last = false;
    }
    fun = "function" === typeof fun ? fun : ths[fun];
    args = pi.utils.to_a(args);
    return function() {
      var rest;
      rest = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return fun.apply(ths || this, last ? rest.concat(args) : args.concat(rest));
    };
  };

  utils.delayed = function(delay, fun, args, ths) {
    if (args == null) {
      args = [];
    }
    return function() {
      return setTimeout(pi.utils.curry(fun, args, ths), delay);
    };
  };

  utils.after = function(delay, fun, ths) {
    return pi.utils.delayed(delay, fun, [], ths)();
  };

  return utils;

})();

pi["export"](pi.utils.curry, 'curry');

pi["export"](pi.utils.delayed, 'delayed');

pi["export"](pi.utils.after, 'after');

pi["export"](pi.utils.debounce, 'debounce');

pi["export"](pi.utils.throttle, 'throttle');



},{"../pi":36}],39:[function(require,module,exports){
'use strict';
var pi, utils, _android_version_rxp, _ios_rxp, _ios_version_rxp, _mac_os_version_rxp, _win_version, _win_version_rxp;

pi = require('../pi');

require('./base');

utils = pi.utils;

_mac_os_version_rxp = /\bMac OS X ([\d\._]+)\b/;

_win_version_rxp = /\bWindows NT ([\d\.]+)\b/;

_ios_rxp = /(iphone|ipod|ipad)/i;

_ios_version_rxp = /\bcpu\s*(?:iphone\s+)?os ([\d\.\-_]+)\b/i;

_android_version_rxp = /\bandroid[\s\-]([\d\-\._]+)\b/i;

_win_version = {
  '6.3': '8.1',
  '6.2': '8',
  '6.1': '7',
  '6.0': 'Vista',
  '5.2': 'XP',
  '5.1': 'XP'
};

pi.utils.browser = (function() {
  function browser() {}

  browser.scrollbar_width = function() {
    return this._scrollbar_width || (this._scrollbar_width = (function() {
      var outer, outerStyle, w;
      outer = document.createElement('div');
      outerStyle = outer.style;
      outerStyle.position = 'absolute';
      outerStyle.width = '100px';
      outerStyle.height = '100px';
      outerStyle.overflow = "scroll";
      outerStyle.top = '-9999px';
      document.body.appendChild(outer);
      w = outer.offsetWidth - outer.clientWidth;
      document.body.removeChild(outer);
      return w;
    })());
  };

  browser.info = function() {
    if (!this._info) {
      this._info = window.bowser != null ? this._extend_info(window.bowser) : this._extend_info();
    }
    return this._info;
  };

  browser._extend_info = function(data) {
    if (data == null) {
      data = {};
    }
    data.os = this.os();
    return data;
  };

  browser.os = function() {
    return this._os || (this._os = (function() {
      var matches, res, ua;
      res = {};
      ua = window.navigator.userAgent;
      if (ua.indexOf('Windows') > -1) {
        res.windows = true;
        if (matches = _win_version_rxp.exec(ua)) {
          res.version = _win_version[matches[1]];
        }
      } else if (ua.indexOf('Macintosh') > -1) {
        res.macos = true;
        if (matches = _mac_os_version_rxp.exec(ua)) {
          res.version = matches[1];
        }
      } else if (ua.indexOf('X11') > -1) {
        res.unix = true;
      } else if (matches = _ios_rxp.exec(ua)) {
        res[matches[1]] = true;
        if (matches = _ios_version_rxp.exec(ua)) {
          res.version = matches[1];
        }
      } else if (ua.indexOf('Android') > -1) {
        res.android = true;
        if (matches = _android_version_rxp.exec(ua)) {
          res.version = matches[1];
        }
      } else if (ua.indexOf('Tizen') > -1) {
        res.tizen = true;
      } else if (ua.indexOf('Blackberry') > -1) {
        res.blackberry = true;
      }
      if (res.version) {
        res.version = res.version.replace(/(_|\-)/g, ".");
      }
      return res;
    })());
  };

  return browser;

})();



},{"../pi":36,"./base":38}],40:[function(require,module,exports){
'use strict';
var pi, utils,
  __slice = [].slice;

pi = require('../pi');

require('./base');

utils = pi.utils;

utils.func = (function() {
  function func() {}

  func.BREAK = "__BREAK__";

  func.wrap = function(target, before, after, options) {
    if (options == null) {
      options = {};
    }
    return function() {
      var a, args, b, res, self;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      self = options["this"] || this;
      if (before != null) {
        b = before.apply(self, args);
        if (b && (options.break_if_value === true)) {
          return b;
        }
        if (b === utils.func.BREAK) {
          return options.break_with;
        }
      }
      res = target.apply(self, args);
      if (after != null) {
        a = after.call(self, res, args, b);
      }
      return res;
    };
  };

  func.append = function(target, callback, options) {
    if (options == null) {
      options = {};
    }
    return pi.utils.func.wrap(target, null, callback, options);
  };

  func.prepend = function(target, callback, options) {
    if (options == null) {
      options = {};
    }
    return pi.utils.func.wrap(target, callback, null, options);
  };

  func.unwrap = function(fun, options, ths) {
    if (options == null) {
      options = {};
    }
    if (ths == null) {
      ths = null;
    }
    return function() {
      if (options.debounce != null) {
        return utils.debounce(options.debounce, fun, ths || this);
      }
      if (options.throttle != null) {
        return utils.throttle(options.throttle, fun, ths || this);
      }
      return fun.bind(ths || this);
    };
  };

  return func;

})();



},{"../pi":36,"./base":38}],41:[function(require,module,exports){
'use strict';
var History;

History = (function() {
  function History() {
    this._storage = [];
    this._position = 0;
  }

  History.prototype.push = function(item) {
    if (this._position < 0) {
      this._storage.splice(this._storage.length + this._position, -this._position);
      this._position = 0;
    }
    return this._storage.push(item);
  };

  History.prototype.pop = function() {
    this._position -= 1;
    return this._storage[this._storage.length + this._position];
  };

  History.prototype.size = function() {
    return this._storage.length;
  };

  History.prototype.clear = function() {
    this._storage.length = 0;
    return this._position = 0;
  };

  return History;

})();

module.exports = History;



},{}],42:[function(require,module,exports){
'use strict';
require('./base');

require('./arr');

require('./obj');

require('./promise');

require('./func');

require('./browser');

require('./time');

require('./logger');

require('./matchers');



},{"./arr":37,"./base":38,"./browser":39,"./func":40,"./logger":43,"./matchers":44,"./obj":45,"./promise":46,"./time":47}],43:[function(require,module,exports){
'use strict';
var info, level, pi, utils, val, _formatter, _log_levels, _show_log,
  __slice = [].slice;

pi = require('../pi');

require('./base');

require('./browser');

require('./time');

utils = pi.utils;

info = utils.browser.info();

_formatter = info.msie ? function(level, args) {
  return console.log("[" + level + "]", args);
} : window.mochaPhantomJS ? function(level, args) {
  return null;
} : function(level, messages) {
  return console.log("%c " + (utils.time.now('%H:%M:%S:%L')) + " [" + level + "]", "color: " + _log_levels[level].color, messages);
};

if (!window.console || !window.console.log) {
  window.console = {
    log: function() {
      return true;
    }
  };
}

pi.log_level || (pi.log_level = "info");

_log_levels = {
  error: {
    color: "#dd0011",
    sort: 4
  },
  debug: {
    color: "#009922",
    sort: 0
  },
  debug_verbose: {
    color: "#eee",
    sort: -1
  },
  info: {
    color: "#1122ff",
    sort: 1
  },
  warning: {
    color: "#ffaa33",
    sort: 2
  }
};

_show_log = function(level) {
  return _log_levels[pi.log_level].sort <= _log_levels[level].sort;
};

utils.log = function() {
  var level, messages;
  level = arguments[0], messages = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
  return _show_log(level) && _formatter(level, messages);
};

for (level in _log_levels) {
  val = _log_levels[level];
  utils[level] = utils.curry(utils.log, level);
}



},{"../pi":36,"./base":38,"./browser":39,"./time":47}],44:[function(require,module,exports){
'use strict';
var pi, utils, _key_operand, _operands,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
  __hasProp = {}.hasOwnProperty;

pi = require('../pi');

require('./base');

utils = pi.utils;

_operands = {
  "?": function(values) {
    return function(value) {
      return __indexOf.call(values, value) >= 0;
    };
  },
  "?&": function(values) {
    return function(value) {
      var v, _i, _len;
      for (_i = 0, _len = values.length; _i < _len; _i++) {
        v = values[_i];
        if (!(__indexOf.call(value, v) >= 0)) {
          return false;
        }
      }
      return true;
    };
  },
  ">": function(val) {
    return function(value) {
      return value >= val;
    };
  },
  "<": function(val) {
    return function(value) {
      return value <= val;
    };
  },
  "~": function(val) {
    if (typeof val === 'string') {
      val = new RegExp(utils.escapeRegexp(val));
    }
    return function(value) {
      return val.test(value);
    };
  }
};

_key_operand = /^([\w\d_]+)(\?&|>|<|~|\?)$/;

pi.utils.matchers = (function() {
  function matchers() {}

  matchers.object = function(obj, all) {
    var key, val, _fn;
    if (all == null) {
      all = true;
    }
    _fn = (function(_this) {
      return function(key, val) {
        if (val == null) {
          return obj[key] = function(value) {
            return !value;
          };
        } else if (typeof val === "object") {
          return obj[key] = _this.object(val, all);
        } else if (!(typeof val === 'function')) {
          return obj[key] = function(value) {
            return val === value;
          };
        }
      };
    })(this);
    for (key in obj) {
      val = obj[key];
      _fn(key, val);
    }
    return function(item) {
      var matcher, _any;
      if (item == null) {
        return false;
      }
      _any = false;
      for (key in obj) {
        matcher = obj[key];
        if (matcher(item[key])) {
          _any = true;
          if (!all) {
            return _any;
          }
        } else {
          if (all) {
            return false;
          }
        }
      }
      return _any;
    };
  };

  matchers.nod = function(string) {
    var query, regexp, selectors, _ref;
    if (string.indexOf(":") > 0) {
      _ref = string.split(":"), selectors = _ref[0], query = _ref[1];
      regexp = new RegExp(query, 'i');
      selectors = selectors.split(',');
      return function(item) {
        var selector, _i, _len, _ref1;
        for (_i = 0, _len = selectors.length; _i < _len; _i++) {
          selector = selectors[_i];
          if (!!((_ref1 = item.find(selector)) != null ? _ref1.text().match(regexp) : void 0)) {
            return true;
          }
        }
        return false;
      };
    } else {
      regexp = new RegExp(string, 'i');
      return function(item) {
        return !!item.text().match(regexp);
      };
    }
  };

  matchers.object_ext = function(obj, all) {
    var key, matchers, matches, val;
    if (all == null) {
      all = true;
    }
    matchers = {};
    for (key in obj) {
      if (!__hasProp.call(obj, key)) continue;
      val = obj[key];
      if ((val != null) && (typeof val === 'object' && !(Array.isArray(val)))) {
        matchers[key] = this.object_ext(val, all);
      } else {
        if ((matches = key.match(_key_operand))) {
          matchers[matches[1]] = _operands[matches[2]](val);
        } else {
          matchers[key] = val;
        }
      }
    }
    return this.object(matchers, all);
  };

  return matchers;

})();



},{"../pi":36,"./base":38}],45:[function(require,module,exports){
'use strict';
var pi, utils;

pi = require('../pi');

require('./base');

utils = pi.utils;

utils.obj = (function() {
  function obj() {}

  obj.get_path = function(obj, path) {
    var key, parts, res;
    parts = path.split(".");
    res = obj;
    while (parts.length) {
      key = parts.shift();
      if (res[key] != null) {
        res = res[key];
      } else {
        return;
      }
    }
    return res;
  };

  obj.set_path = function(obj, path, val) {
    var key, parts, res;
    parts = path.split(".");
    res = obj;
    while (parts.length > 1) {
      key = parts.shift();
      if (res[key] == null) {
        res[key] = {};
      }
      res = res[key];
    }
    return res[parts[0]] = val;
  };

  obj.get_class_path = function(pckg, path) {
    path = path.split('.').map((function(_this) {
      return function(p) {
        return utils.camelCase(p);
      };
    })(this)).join('.');
    return this.get_path(pckg, path);
  };

  obj.wrap = function(key, obj) {
    var data;
    data = {};
    data[key] = obj;
    return data;
  };

  obj.from_arr = function(arr) {
    var data, i, _, _i, _len;
    data = {};
    for (i = _i = 0, _len = arr.length; _i < _len; i = _i += 2) {
      _ = arr[i];
      data[arr[i]] = arr[i + 1];
    }
    return data;
  };

  return obj;

})();



},{"../pi":36,"./base":38}],46:[function(require,module,exports){
'use strict';
var pi, utils;

pi = require('../pi');

require('./base');

utils = pi.utils;

utils.promise = (function() {
  function promise() {}

  promise.as_promise = function(fun, resolved) {
    if (resolved == null) {
      resolved = true;
    }
    return new Promise(function(resolve, reject) {
      if (resolved) {
        return resolve(fun.call(null));
      } else {
        return reject(fun.call(null));
      }
    });
  };

  promise.resolved_promise = function(data) {
    return new Promise(function(resolve) {
      return resolve(data);
    });
  };

  promise.rejected_promise = function(error) {
    return new Promise(function(_, reject) {
      return reject(error);
    });
  };

  return promise;

})();



},{"../pi":36,"./base":38}],47:[function(require,module,exports){
'use strict';
var pi, utils, _formatter, _pad, _reg, _splitter;

pi = require('../pi');

require('./base');

utils = pi.utils;

_reg = /%([a-zA-Z])/g;

_splitter = (function() {
  if ("%a".split(_reg).length === 0) {
    return function(str) {
      var flag, len, matches, parts, res;
      matches = str.match(_reg);
      parts = str.split(_reg);
      res = [];
      if (str[0] === "%") {
        res.push("", matches.shift()[1]);
      }
      len = matches.length + parts.length;
      flag = false;
      while (len > 0) {
        res.push(flag ? matches.shift()[1] : parts.shift());
        flag = !flag;
        len--;
      }
      return res;
    };
  } else {
    return function(str) {
      return str.split(_reg);
    };
  }
})();

_pad = function(val, offset) {
  var n;
  if (offset == null) {
    offset = 1;
  }
  n = 10;
  while (offset) {
    if (val < n) {
      val = "0" + val;
    }
    n *= 10;
    offset--;
  }
  return val;
};

_formatter = {
  "H": function(d) {
    return _pad(d.getHours());
  },
  "k": function(d) {
    return d.getHours();
  },
  "I": function(d) {
    return _pad(_formatter.l(d));
  },
  "l": function(d) {
    var h;
    h = d.getHours();
    if (h > 12) {
      return h - 12;
    } else {
      return h;
    }
  },
  "M": function(d) {
    return _pad(d.getMinutes());
  },
  "S": function(d) {
    return _pad(d.getSeconds());
  },
  "L": function(d) {
    return _pad(d.getMilliseconds(), 2);
  },
  "z": function(d) {
    var offset, sign;
    offset = d.getTimezoneOffset();
    sign = offset > 0 ? "-" : "+";
    offset = Math.abs(offset);
    return sign + _pad(Math.floor(offset / 60)) + ":" + _pad(offset % 60);
  },
  "Y": function(d) {
    return d.getFullYear();
  },
  "y": function(d) {
    return (d.getFullYear() + "").slice(2);
  },
  "m": function(d) {
    return _pad(d.getMonth() + 1);
  },
  "d": function(d) {
    return _pad(d.getDate());
  },
  "P": function(d) {
    if (d.getHours() > 11) {
      return "PM";
    } else {
      return "AM";
    }
  },
  "p": function(d) {
    return _formatter.P(d).toLowerCase();
  }
};

utils.time = {
  normalize_time: function(t) {
    if (typeof t === 'number' && t < 4000000000) {
      t *= 1000;
    }
    return new Date(t);
  },
  now: function(fmt) {
    return this.format(new Date(), fmt);
  },
  format: function(t, fmt) {
    var flag, fmt_arr, i, res, _i, _len;
    t = this.normalize_time(t);
    if (fmt == null) {
      return t;
    }
    fmt_arr = _splitter(fmt);
    flag = false;
    res = "";
    for (_i = 0, _len = fmt_arr.length; _i < _len; _i++) {
      i = fmt_arr[_i];
      res += (flag ? _formatter[i].call(null, t) : i);
      flag = !flag;
    }
    return res;
  },
  duration: function(val, milliseconds, show_milliseconds) {
    var arr, m, ms, res;
    if (milliseconds == null) {
      milliseconds = false;
    }
    if (show_milliseconds == null) {
      show_milliseconds = false;
    }
    if (milliseconds) {
      ms = val % 1000;
      val = (val / 1000) | 0;
    }
    arr = [];
    m = (val / 60) | 0;
    arr.push((m / 60) | 0);
    arr.push(_pad(m % 60));
    arr.push(_pad(val % 60));
    res = arr.join(":");
    if ((ms != null) && show_milliseconds) {
      res += "." + (_pad(ms, 2));
    }
    return res;
  }
};



},{"../pi":36,"./base":38}],48:[function(require,module,exports){
(function (process){
/* parser generated by jison 0.4.15 */
/*
  Returns a Parser object of the following structure:

  Parser: {
    yy: {}
  }

  Parser.prototype: {
    yy: {},
    trace: function(),
    symbols_: {associative list: name ==> number},
    terminals_: {associative list: number ==> name},
    productions_: [...],
    performAction: function anonymous(yytext, yyleng, yylineno, yy, yystate, $$, _$),
    table: [...],
    defaultActions: {...},
    parseError: function(str, hash),
    parse: function(input),

    lexer: {
        EOF: 1,
        parseError: function(str, hash),
        setInput: function(input),
        input: function(),
        unput: function(str),
        more: function(),
        less: function(n),
        pastInput: function(),
        upcomingInput: function(),
        showPosition: function(),
        test_match: function(regex_match_array, rule_index),
        next: function(),
        lex: function(),
        begin: function(condition),
        popState: function(),
        _currentRules: function(),
        topState: function(),
        pushState: function(condition),

        options: {
            ranges: boolean           (optional: true ==> token location info will include a .range[] member)
            flex: boolean             (optional: true ==> flex-like lexing behaviour where the rules are tested exhaustively to find the longest match)
            backtrack_lexer: boolean  (optional: true ==> lexer regexes are tested in order and for each matching regex the action code is invoked; the lexer terminates the scan when a token is returned by the action code)
        },

        performAction: function(yy, yy_, $avoiding_name_collisions, YY_START),
        rules: [...],
        conditions: {associative list: name ==> set},
    }
  }


  token location info (@$, _$, etc.): {
    first_line: n,
    last_line: n,
    first_column: n,
    last_column: n,
    range: [start_number, end_number]       (where the numbers are indexes into the input string, regular zero-based)
  }


  the parseError function receives a 'hash' object with these members for lexer and parser errors: {
    text:        (matched text)
    token:       (the produced terminal token, if any)
    line:        (yylineno)
  }
  while parser (grammar) errors will also provide these members, i.e. parser errors deliver a superset of attributes: {
    loc:         (yylloc)
    expected:    (string describing the set of expected tokens)
    recoverable: (boolean: TRUE when the parser has a error recovery rule available for this particular error)
  }
*/
var parser = (function(){
var o=function(k,v,o,l){for(o=o||{},l=k.length;l--;o[k[l]]=v);return o},$V0=[1,6],$V1=[1,16],$V2=[1,17],$V3=[1,11],$V4=[1,12],$V5=[1,13],$V6=[5,11,33],$V7=[2,2],$V8=[2,4],$V9=[1,21],$Va=[1,22],$Vb=[1,23],$Vc=[1,19],$Vd=[5,11,21,28,29,30,32,33],$Ve=[5,11,15,21,28,29,30,32,33],$Vf=[2,12],$Vg=[1,30],$Vh=[19,20,24,25,26],$Vi=[1,37],$Vj=[2,22];
var parser = {trace: function trace() { },
yy: {},
symbols_: {"error":2,"expressions":3,"e":4,"EOF":5,"group_e":6,"ternary":7,"simple_e":8,"(":9,"object":10,")":11,"method_chain":12,"val":13,"method":14,".":15,"resource":16,"key":17,"args":18,"RES":19,"KEY":20,",":21,"key_val":22,":":23,"NUMBER":24,"BOOL":25,"STRING":26,"op":27,"EQL":28,"MORE":29,"LESS":30,"cond":31,"TIF":32,"TELSE":33,"$accept":0,"$end":1},
terminals_: {2:"error",5:"EOF",9:"(",11:")",15:".",19:"RES",20:"KEY",21:",",23:":",24:"NUMBER",25:"BOOL",26:"STRING",28:"EQL",29:"MORE",30:"LESS",32:"TIF",33:"TELSE"},
productions_: [0,[3,2],[4,1],[4,1],[4,1],[4,3],[6,3],[8,1],[8,1],[12,1],[12,3],[14,1],[14,1],[14,4],[16,4],[16,4],[16,1],[17,1],[18,3],[18,3],[18,1],[18,1],[18,0],[10,3],[10,1],[22,3],[13,1],[13,1],[13,1],[27,1],[27,1],[27,1],[31,3],[7,5],[7,5]],
performAction: function anonymous(yytext, yyleng, yylineno, yy, yystate /* action[1] */, $$ /* vstack */, _$ /* lstack */) {
/* this == yyval */

var $0 = $$.length - 1;
switch (yystate) {
case 1:
 return $$[$0-1]; 
break;
case 2: case 3: case 4: case 9: case 11: case 24:
this.$ = $$[$0];
break;
case 5:
this.$ = {code: 'simple', value: fn_arr_obj($$[$0-1])};
break;
case 6:
this.$ = $$[$0-1];
break;
case 7:
this.$ = {code: 'chain', value: $$[$0]};
break;
case 8:
this.$ = {code: 'simple', value: $$[$0]};
break;
case 10: case 23:
this.$ = $$[$0-2].concat($$[$0]);
break;
case 12:
this.$ = [{code: 'prop', name: $$[$0]}];
break;
case 13:
this.$ = [{code: 'call', name: $$[$0-3], args: $$[$0-1]}];
break;
case 14:
this.$ = [{code: 'res', name: $$[$0-3]}, {code: 'call', name: 'view', args: [{code: 'simple', value: fn_arr_obj($$[$0-1])}]}];
break;
case 15:
this.$ = [{code: 'res', name: $$[$0-3]}, {code: 'call', name: 'get', args: [{code: 'simple', value: $$[$0-1]}]}];
break;
case 16:
this.$ = [{code: 'res', name: $$[$0]}];
break;
case 17:
this.$ = yytext;
break;
case 18: case 19:
this.$ = [$$[$0-2]].concat($$[$0]);
break;
case 20:
this.$ = [$$[$0]];
break;
case 21:
this.$ = [{code: 'simple', value: fn_arr_obj($$[$0])}];
break;
case 22:
this.$ = [];
break;
case 25:
this.$ = [$$[$0-2],$$[$0]];
break;
case 26:
this.$ = Number(yytext);
break;
case 27:
this.$ = yytext=="true";
break;
case 28:
this.$ = yytext.replace(/(^['"]|['"]$)/g,'');
break;
case 29: case 30: case 31:
this.$ = yytext.replace(/(^\s+|\s+$)/g,'');
break;
case 32:
this.$ = {left: $$[$0-2], right: $$[$0], type: $$[$0-1]};
break;
case 33:
this.$ = {code: 'if', cond: $$[$0-4], left: $$[$0-2], right: $$[$0]};
break;
case 34:
this.$ = {code: 'if', cond: {left: $$[$0-4], type: 'bool'}, left: $$[$0-2], right: $$[$0]};
break;
}
},
table: [{3:1,4:2,6:3,7:4,8:5,9:$V0,12:8,13:9,14:10,16:14,17:15,19:$V1,20:$V2,24:$V3,25:$V4,26:$V5,31:7},{1:[3]},{5:[1,18]},o($V6,$V7),o($V6,[2,3]),o($V6,$V8,{27:20,28:$V9,29:$Va,30:$Vb,32:$Vc}),{4:25,6:3,7:4,8:5,9:$V0,10:24,12:8,13:9,14:10,16:14,17:27,19:$V1,20:$V2,22:26,24:$V3,25:$V4,26:$V5,31:7},{32:[1,28]},o($Vd,[2,7]),o($Vd,[2,8]),o($Vd,[2,9],{15:[1,29]}),o($Vd,[2,26]),o($Vd,[2,27]),o($Vd,[2,28]),o($Ve,[2,11]),o($Ve,$Vf,{9:$Vg}),o($Ve,[2,16],{9:[1,31]}),o([5,9,11,15,21,23,28,29,30,32,33],[2,17]),{1:[2,1]},{4:32,6:3,7:4,8:5,9:$V0,12:8,13:9,14:10,16:14,17:15,19:$V1,20:$V2,24:$V3,25:$V4,26:$V5,31:7},{8:33,12:8,13:9,14:10,16:14,17:15,19:$V1,20:$V2,24:$V3,25:$V4,26:$V5},o($Vh,[2,29]),o($Vh,[2,30]),o($Vh,[2,31]),{11:[1,34]},{11:[1,35]},{11:[2,24],21:[1,36]},o([11,15,21,28,29,30,32],$Vf,{9:$Vg,23:$Vi}),{4:38,6:3,7:4,8:5,9:$V0,12:8,13:9,14:10,16:14,17:15,19:$V1,20:$V2,24:$V3,25:$V4,26:$V5,31:7},{12:39,14:10,16:14,17:15,19:$V1,20:$V2},{4:43,6:41,7:4,8:42,9:$V0,10:44,11:$Vj,12:8,13:9,14:10,16:14,17:27,18:40,19:$V1,20:$V2,22:26,24:$V3,25:$V4,26:$V5,31:7},{10:45,13:46,17:47,20:$V2,22:26,24:$V3,25:$V4,26:$V5},{33:[1,48]},{32:[2,32]},o($V6,[2,5]),o([5,11,21,33],[2,6]),{10:49,17:47,20:$V2,22:26},{13:50,24:$V3,25:$V4,26:$V5},{33:[1,51]},o($Vd,[2,10]),{11:[1,52]},{11:$V7,21:[1,53]},{11:$V8,21:[1,54],27:20,28:$V9,29:$Va,30:$Vb,32:$Vc},{11:[2,20]},{11:[2,21]},{11:[1,55]},{11:[1,56]},{23:$Vi},{4:57,6:3,7:4,8:5,9:$V0,12:8,13:9,14:10,16:14,17:15,19:$V1,20:$V2,24:$V3,25:$V4,26:$V5,31:7},{11:[2,23]},o([11,21],[2,25]),{4:58,6:3,7:4,8:5,9:$V0,12:8,13:9,14:10,16:14,17:15,19:$V1,20:$V2,24:$V3,25:$V4,26:$V5,31:7},o($Ve,[2,13]),{4:43,6:41,7:4,8:42,9:$V0,10:44,11:$Vj,12:8,13:9,14:10,16:14,17:27,18:59,19:$V1,20:$V2,22:26,24:$V3,25:$V4,26:$V5,31:7},{4:43,6:41,7:4,8:42,9:$V0,10:44,11:$Vj,12:8,13:9,14:10,16:14,17:27,18:60,19:$V1,20:$V2,22:26,24:$V3,25:$V4,26:$V5,31:7},o($Ve,[2,14]),o($Ve,[2,15]),o($V6,[2,34]),o($V6,[2,33]),{11:[2,18]},{11:[2,19]}],
defaultActions: {18:[2,1],33:[2,32],43:[2,20],44:[2,21],49:[2,23],59:[2,18],60:[2,19]},
parseError: function parseError(str, hash) {
    if (hash.recoverable) {
        this.trace(str);
    } else {
        throw new Error(str);
    }
},
parse: function parse(input) {
    var self = this, stack = [0], tstack = [], vstack = [null], lstack = [], table = this.table, yytext = '', yylineno = 0, yyleng = 0, recovering = 0, TERROR = 2, EOF = 1;
    var args = lstack.slice.call(arguments, 1);
    var lexer = Object.create(this.lexer);
    var sharedState = { yy: {} };
    for (var k in this.yy) {
        if (Object.prototype.hasOwnProperty.call(this.yy, k)) {
            sharedState.yy[k] = this.yy[k];
        }
    }
    lexer.setInput(input, sharedState.yy);
    sharedState.yy.lexer = lexer;
    sharedState.yy.parser = this;
    if (typeof lexer.yylloc == 'undefined') {
        lexer.yylloc = {};
    }
    var yyloc = lexer.yylloc;
    lstack.push(yyloc);
    var ranges = lexer.options && lexer.options.ranges;
    if (typeof sharedState.yy.parseError === 'function') {
        this.parseError = sharedState.yy.parseError;
    } else {
        this.parseError = Object.getPrototypeOf(this).parseError;
    }
    function popStack(n) {
        stack.length = stack.length - 2 * n;
        vstack.length = vstack.length - n;
        lstack.length = lstack.length - n;
    }
    _token_stack:
        function lex() {
            var token;
            token = lexer.lex() || EOF;
            if (typeof token !== 'number') {
                token = self.symbols_[token] || token;
            }
            return token;
        }
    var symbol, preErrorSymbol, state, action, a, r, yyval = {}, p, len, newState, expected;
    while (true) {
        state = stack[stack.length - 1];
        if (this.defaultActions[state]) {
            action = this.defaultActions[state];
        } else {
            if (symbol === null || typeof symbol == 'undefined') {
                symbol = lex();
            }
            action = table[state] && table[state][symbol];
        }
                    if (typeof action === 'undefined' || !action.length || !action[0]) {
                var errStr = '';
                expected = [];
                for (p in table[state]) {
                    if (this.terminals_[p] && p > TERROR) {
                        expected.push('\'' + this.terminals_[p] + '\'');
                    }
                }
                if (lexer.showPosition) {
                    errStr = 'Parse error on line ' + (yylineno + 1) + ':\n' + lexer.showPosition() + '\nExpecting ' + expected.join(', ') + ', got \'' + (this.terminals_[symbol] || symbol) + '\'';
                } else {
                    errStr = 'Parse error on line ' + (yylineno + 1) + ': Unexpected ' + (symbol == EOF ? 'end of input' : '\'' + (this.terminals_[symbol] || symbol) + '\'');
                }
                this.parseError(errStr, {
                    text: lexer.match,
                    token: this.terminals_[symbol] || symbol,
                    line: lexer.yylineno,
                    loc: yyloc,
                    expected: expected
                });
            }
        if (action[0] instanceof Array && action.length > 1) {
            throw new Error('Parse Error: multiple actions possible at state: ' + state + ', token: ' + symbol);
        }
        switch (action[0]) {
        case 1:
            stack.push(symbol);
            vstack.push(lexer.yytext);
            lstack.push(lexer.yylloc);
            stack.push(action[1]);
            symbol = null;
            if (!preErrorSymbol) {
                yyleng = lexer.yyleng;
                yytext = lexer.yytext;
                yylineno = lexer.yylineno;
                yyloc = lexer.yylloc;
                if (recovering > 0) {
                    recovering--;
                }
            } else {
                symbol = preErrorSymbol;
                preErrorSymbol = null;
            }
            break;
        case 2:
            len = this.productions_[action[1]][1];
            yyval.$ = vstack[vstack.length - len];
            yyval._$ = {
                first_line: lstack[lstack.length - (len || 1)].first_line,
                last_line: lstack[lstack.length - 1].last_line,
                first_column: lstack[lstack.length - (len || 1)].first_column,
                last_column: lstack[lstack.length - 1].last_column
            };
            if (ranges) {
                yyval._$.range = [
                    lstack[lstack.length - (len || 1)].range[0],
                    lstack[lstack.length - 1].range[1]
                ];
            }
            r = this.performAction.apply(yyval, [
                yytext,
                yyleng,
                yylineno,
                sharedState.yy,
                action[1],
                vstack,
                lstack
            ].concat(args));
            if (typeof r !== 'undefined') {
                return r;
            }
            if (len) {
                stack = stack.slice(0, -1 * len * 2);
                vstack = vstack.slice(0, -1 * len);
                lstack = lstack.slice(0, -1 * len);
            }
            stack.push(this.productions_[action[1]][0]);
            vstack.push(yyval.$);
            lstack.push(yyval._$);
            newState = table[stack[stack.length - 2]][stack[stack.length - 1]];
            stack.push(newState);
            break;
        case 3:
            return true;
        }
    }
    return true;
}};

  var fn_arr_obj = function(arr){ 
     var tmp = {};
     for(var i=0,size=arr.length; i<size; i+=2)
       tmp[arr[i]] = arr[i+1];
     return tmp;
  };
/* generated by jison-lex 0.3.4 */
var lexer = (function(){
var lexer = ({

EOF:1,

parseError:function parseError(str, hash) {
        if (this.yy.parser) {
            this.yy.parser.parseError(str, hash);
        } else {
            throw new Error(str);
        }
    },

// resets the lexer, sets new input
setInput:function (input, yy) {
        this.yy = yy || this.yy || {};
        this._input = input;
        this._more = this._backtrack = this.done = false;
        this.yylineno = this.yyleng = 0;
        this.yytext = this.matched = this.match = '';
        this.conditionStack = ['INITIAL'];
        this.yylloc = {
            first_line: 1,
            first_column: 0,
            last_line: 1,
            last_column: 0
        };
        if (this.options.ranges) {
            this.yylloc.range = [0,0];
        }
        this.offset = 0;
        return this;
    },

// consumes and returns one char from the input
input:function () {
        var ch = this._input[0];
        this.yytext += ch;
        this.yyleng++;
        this.offset++;
        this.match += ch;
        this.matched += ch;
        var lines = ch.match(/(?:\r\n?|\n).*/g);
        if (lines) {
            this.yylineno++;
            this.yylloc.last_line++;
        } else {
            this.yylloc.last_column++;
        }
        if (this.options.ranges) {
            this.yylloc.range[1]++;
        }

        this._input = this._input.slice(1);
        return ch;
    },

// unshifts one char (or a string) into the input
unput:function (ch) {
        var len = ch.length;
        var lines = ch.split(/(?:\r\n?|\n)/g);

        this._input = ch + this._input;
        this.yytext = this.yytext.substr(0, this.yytext.length - len);
        //this.yyleng -= len;
        this.offset -= len;
        var oldLines = this.match.split(/(?:\r\n?|\n)/g);
        this.match = this.match.substr(0, this.match.length - 1);
        this.matched = this.matched.substr(0, this.matched.length - 1);

        if (lines.length - 1) {
            this.yylineno -= lines.length - 1;
        }
        var r = this.yylloc.range;

        this.yylloc = {
            first_line: this.yylloc.first_line,
            last_line: this.yylineno + 1,
            first_column: this.yylloc.first_column,
            last_column: lines ?
                (lines.length === oldLines.length ? this.yylloc.first_column : 0)
                 + oldLines[oldLines.length - lines.length].length - lines[0].length :
              this.yylloc.first_column - len
        };

        if (this.options.ranges) {
            this.yylloc.range = [r[0], r[0] + this.yyleng - len];
        }
        this.yyleng = this.yytext.length;
        return this;
    },

// When called from action, caches matched text and appends it on next action
more:function () {
        this._more = true;
        return this;
    },

// When called from action, signals the lexer that this rule fails to match the input, so the next matching rule (regex) should be tested instead.
reject:function () {
        if (this.options.backtrack_lexer) {
            this._backtrack = true;
        } else {
            return this.parseError('Lexical error on line ' + (this.yylineno + 1) + '. You can only invoke reject() in the lexer when the lexer is of the backtracking persuasion (options.backtrack_lexer = true).\n' + this.showPosition(), {
                text: "",
                token: null,
                line: this.yylineno
            });

        }
        return this;
    },

// retain first n characters of the match
less:function (n) {
        this.unput(this.match.slice(n));
    },

// displays already matched input, i.e. for error messages
pastInput:function () {
        var past = this.matched.substr(0, this.matched.length - this.match.length);
        return (past.length > 20 ? '...':'') + past.substr(-20).replace(/\n/g, "");
    },

// displays upcoming input, i.e. for error messages
upcomingInput:function () {
        var next = this.match;
        if (next.length < 20) {
            next += this._input.substr(0, 20-next.length);
        }
        return (next.substr(0,20) + (next.length > 20 ? '...' : '')).replace(/\n/g, "");
    },

// displays the character position where the lexing error occurred, i.e. for error messages
showPosition:function () {
        var pre = this.pastInput();
        var c = new Array(pre.length + 1).join("-");
        return pre + this.upcomingInput() + "\n" + c + "^";
    },

// test the lexed token: return FALSE when not a match, otherwise return token
test_match:function (match, indexed_rule) {
        var token,
            lines,
            backup;

        if (this.options.backtrack_lexer) {
            // save context
            backup = {
                yylineno: this.yylineno,
                yylloc: {
                    first_line: this.yylloc.first_line,
                    last_line: this.last_line,
                    first_column: this.yylloc.first_column,
                    last_column: this.yylloc.last_column
                },
                yytext: this.yytext,
                match: this.match,
                matches: this.matches,
                matched: this.matched,
                yyleng: this.yyleng,
                offset: this.offset,
                _more: this._more,
                _input: this._input,
                yy: this.yy,
                conditionStack: this.conditionStack.slice(0),
                done: this.done
            };
            if (this.options.ranges) {
                backup.yylloc.range = this.yylloc.range.slice(0);
            }
        }

        lines = match[0].match(/(?:\r\n?|\n).*/g);
        if (lines) {
            this.yylineno += lines.length;
        }
        this.yylloc = {
            first_line: this.yylloc.last_line,
            last_line: this.yylineno + 1,
            first_column: this.yylloc.last_column,
            last_column: lines ?
                         lines[lines.length - 1].length - lines[lines.length - 1].match(/\r?\n?/)[0].length :
                         this.yylloc.last_column + match[0].length
        };
        this.yytext += match[0];
        this.match += match[0];
        this.matches = match;
        this.yyleng = this.yytext.length;
        if (this.options.ranges) {
            this.yylloc.range = [this.offset, this.offset += this.yyleng];
        }
        this._more = false;
        this._backtrack = false;
        this._input = this._input.slice(match[0].length);
        this.matched += match[0];
        token = this.performAction.call(this, this.yy, this, indexed_rule, this.conditionStack[this.conditionStack.length - 1]);
        if (this.done && this._input) {
            this.done = false;
        }
        if (token) {
            return token;
        } else if (this._backtrack) {
            // recover context
            for (var k in backup) {
                this[k] = backup[k];
            }
            return false; // rule action called reject() implying the next rule should be tested instead.
        }
        return false;
    },

// return next match in input
next:function () {
        if (this.done) {
            return this.EOF;
        }
        if (!this._input) {
            this.done = true;
        }

        var token,
            match,
            tempMatch,
            index;
        if (!this._more) {
            this.yytext = '';
            this.match = '';
        }
        var rules = this._currentRules();
        for (var i = 0; i < rules.length; i++) {
            tempMatch = this._input.match(this.rules[rules[i]]);
            if (tempMatch && (!match || tempMatch[0].length > match[0].length)) {
                match = tempMatch;
                index = i;
                if (this.options.backtrack_lexer) {
                    token = this.test_match(tempMatch, rules[i]);
                    if (token !== false) {
                        return token;
                    } else if (this._backtrack) {
                        match = false;
                        continue; // rule action called reject() implying a rule MISmatch.
                    } else {
                        // else: this is a lexer rule which consumes input without producing a token (e.g. whitespace)
                        return false;
                    }
                } else if (!this.options.flex) {
                    break;
                }
            }
        }
        if (match) {
            token = this.test_match(match, rules[index]);
            if (token !== false) {
                return token;
            }
            // else: this is a lexer rule which consumes input without producing a token (e.g. whitespace)
            return false;
        }
        if (this._input === "") {
            return this.EOF;
        } else {
            return this.parseError('Lexical error on line ' + (this.yylineno + 1) + '. Unrecognized text.\n' + this.showPosition(), {
                text: "",
                token: null,
                line: this.yylineno
            });
        }
    },

// return next match that has a token
lex:function lex() {
        var r = this.next();
        if (r) {
            return r;
        } else {
            return this.lex();
        }
    },

// activates a new lexer condition state (pushes the new lexer condition state onto the condition stack)
begin:function begin(condition) {
        this.conditionStack.push(condition);
    },

// pop the previously active lexer condition state off the condition stack
popState:function popState() {
        var n = this.conditionStack.length - 1;
        if (n > 0) {
            return this.conditionStack.pop();
        } else {
            return this.conditionStack[0];
        }
    },

// produce the lexer rule set which is active for the currently active lexer condition state
_currentRules:function _currentRules() {
        if (this.conditionStack.length && this.conditionStack[this.conditionStack.length - 1]) {
            return this.conditions[this.conditionStack[this.conditionStack.length - 1]].rules;
        } else {
            return this.conditions["INITIAL"].rules;
        }
    },

// return the currently active lexer condition state; when an index argument is provided it produces the N-th previous condition state, if available
topState:function topState(n) {
        n = this.conditionStack.length - 1 - Math.abs(n || 0);
        if (n >= 0) {
            return this.conditionStack[n];
        } else {
            return "INITIAL";
        }
    },

// alias for begin(condition)
pushState:function pushState(condition) {
        this.begin(condition);
    },

// return the number of states currently on the stack
stateStackSize:function stateStackSize() {
        return this.conditionStack.length;
    },
options: {},
performAction: function anonymous(yy,yy_,$avoiding_name_collisions,YY_START) {
var YYSTATE=YY_START;
switch($avoiding_name_collisions) {
case 0:/* skip whitespace */
break;
case 1:return 24
break;
case 2:return 33
break;
case 3:return 23
break;
case 4:return 32
break;
case 5:return '?'
break;
case 6:return 21
break;
case 7:return 9
break;
case 8:return 11
break;
case 9:return 26
break;
case 10:return 26
break;
case 11:return 25
break;
case 12:return 19
break;
case 13:return 20
break;
case 14:return 15
break;
case 15:return 28
break;
case 16:return 29
break;
case 17:return 30
break;
case 18:return 5
break;
case 19:return 'INVALID'
break;
}
},
rules: [/^(?:\s\s+)/,/^(?:[0-9]+(\.[0-9]+)?\b)/,/^(?:\s+:\s+)/,/^(?::\s*)/,/^(?:\s+\?\s+)/,/^(?:\?)/,/^(?:,\s*)/,/^(?:\()/,/^(?:\))/,/^(?:"(\\"|[^\"])*")/,/^(?:'(\\'|[^\'])*')/,/^(?:(true|false))/,/^(?:[A-Z][\w\d]*)/,/^(?:\w[\w\d]*)/,/^(?:\.)/,/^(?:\s*=\s*)/,/^(?:\s*>\s*)/,/^(?:\s*<\s*)/,/^(?:$)/,/^(?:.)/],
conditions: {"INITIAL":{"rules":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19],"inclusive":true}}
});
return lexer;
})();
parser.lexer = lexer;
function Parser () {
  this.yy = {};
}
Parser.prototype = parser;parser.Parser = Parser;
return new Parser;
})();


if (typeof require !== 'undefined' && typeof exports !== 'undefined') {
exports.parser = parser;
exports.Parser = parser.Parser;
exports.parse = function () { return parser.parse.apply(parser, arguments); };
exports.main = function commonjsMain(args) {
    if (!args[1]) {
        console.log('Usage: '+args[0]+' FILE');
        process.exit(1);
    }
    var source = require('fs').readFileSync(require('path').normalize(args[1]), "utf8");
    return exports.parser.parse(source);
};
if (typeof module !== 'undefined' && require.main === module) {
  exports.main(process.argv.slice(1));
}
}
}).call(this,require('_process'))
},{"_process":81,"fs":79,"path":80}],49:[function(require,module,exports){
'use strict';
var pi, utils;

pi = require('../core');

require('./net');

utils = pi.utils;

pi.net.IframeUpload = (function() {
  function IframeUpload() {}

  IframeUpload._build_iframe = function(id) {
    var iframe;
    iframe = pi.Nod.create('iframe');
    iframe.attrs({
      id: id,
      name: id,
      width: 0,
      height: 0,
      border: 0
    });
    iframe.styles({
      width: 0,
      height: 0,
      border: 'none'
    });
    return iframe;
  };

  IframeUpload._build_input = function(name, value) {
    var input;
    input = pi.Nod.create('input');
    input.node.type = 'hidden';
    input.node.name = name;
    input.node.value = value;
    return input;
  };

  IframeUpload._build_form = function(form, iframe, params, url, method) {
    var param, _i, _len;
    form.attrs({
      target: iframe,
      action: url,
      method: method,
      enctype: "multipart/form-data",
      encoding: "multipart/form-data"
    });
    for (_i = 0, _len = params.length; _i < _len; _i++) {
      param = params[_i];
      form.append(this._build_input(param.name, param.value));
    }
    form.append(this._build_input('__iframe__', iframe));
    return form;
  };

  IframeUpload.upload = function(form, url, params, method) {
    return new Promise((function(_this) {
      return function(resolve) {
        var iframe, iframe_id;
        iframe_id = "iframe_" + (utils.uid());
        iframe = _this._build_iframe(iframe_id);
        form = _this._build_form(form, iframe_id, params, url, method);
        pi.Nod.body.append(iframe);
        iframe.on("load", function() {
          var response;
          if (iframe.node.contentDocument.readyState === 'complete') {
            response = iframe.node.contentDocument.getElementsByTagName("body")[0];
            utils.after(500, function() {
              return iframe.remove();
            });
            iframe.off();
            return resolve(response);
          }
        });
        return form.node.submit();
      };
    })(this));
  };

  return IframeUpload;

})();



},{"../core":34,"./net":51}],50:[function(require,module,exports){
'use strict';
require('./net');

require('./iframe.upload');



},{"./iframe.upload":49,"./net":51}],51:[function(require,module,exports){
'use strict';
var method, pi, utils, _i, _len, _ref,
  __hasProp = {}.hasOwnProperty;

pi = require('../core');

utils = pi.utils;

pi.Net = (function() {
  function Net() {}

  Net._prepare_response = function(xhr) {
    var response, type;
    type = xhr.getResponseHeader('Content-Type');
    response = /json/.test(type) ? JSON.parse(xhr.responseText) : xhr.responseText;
    utils.debug('XHR response', xhr.responseText);
    return response;
  };

  Net._prepare_error = function(xhr) {
    var response, type;
    type = xhr.getResponseHeader('Content-Type');
    return response = /json/.test(type) ? JSON.parse(xhr.responseText || ("{\"status\":" + xhr.statusText + "}")) : xhr.responseText || xhr.statusText;
  };

  Net._is_app_error = function(status) {
    return status >= 400 && status < 500;
  };

  Net._is_success = function(status) {
    return (status >= 200 && status < 300) || (status === 304);
  };

  Net._with_prefix = function(prefix, key) {
    if (prefix) {
      return "" + prefix + "[" + key + "]";
    } else {
      return key;
    }
  };

  Net._to_params = function(data, prefix) {
    var item, key, params, val, _i, _len;
    if (prefix == null) {
      prefix = "";
    }
    params = [];
    if (data == null) {
      return params;
    }
    if (typeof data !== 'object') {
      params.push({
        name: prefix,
        value: data
      });
    } else {
      if (data instanceof Date) {
        params.push({
          name: prefix,
          value: data.getTime()
        });
      } else if (data instanceof Array) {
        prefix += "[]";
        for (_i = 0, _len = data.length; _i < _len; _i++) {
          item = data[_i];
          params = params.concat(this._to_params(item, prefix));
        }
      } else if (!!window.File && ((data instanceof File) || (data instanceof Blob))) {
        params.push({
          name: prefix,
          value: data
        });
      } else {
        for (key in data) {
          if (!__hasProp.call(data, key)) continue;
          val = data[key];
          params = params.concat(this._to_params(val, this._with_prefix(prefix, key)));
        }
      }
    }
    return params;
  };

  Net._data_to_query = function(data) {
    var param, q, _i, _len, _ref;
    q = [];
    _ref = this._to_params(data);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      param = _ref[_i];
      q.push("" + param.name + "=" + (encodeURIComponent(param.value)));
    }
    return q.join("&");
  };

  Net._data_to_form = (!!window.FormData ? function(data) {
    var form, param, _i, _len, _ref;
    form = new FormData();
    _ref = Net._to_params(data);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      param = _ref[_i];
      form.append(param.name, param.value);
    }
    return form;
  } : function(data) {
    return Net._data_to_query(data);
  });

  Net.use_json = true;

  Net.headers = [];

  Net.request = function(method, url, data, options, xhr) {
    if (options == null) {
      options = {};
    }
    return new Promise((function(_this) {
      return function(resolve, reject) {
        var key, q, req, use_json, value, _headers;
        req = xhr || new XMLHttpRequest();
        use_json = options.json != null ? options.json : _this.use_json;
        _headers = utils.merge(pi.net.headers, options.headers || {});
        if (method === 'GET') {
          q = _this._data_to_query(data);
          if (q) {
            if (url.indexOf("?") < 0) {
              url += "?";
            } else {
              url += "&";
            }
            url += "" + q;
          }
          data = null;
        } else {
          if (use_json) {
            _headers['Content-Type'] = 'application/json';
            if (data != null) {
              data = JSON.stringify(data);
            }
          } else {
            data = _this._data_to_form(data);
          }
        }
        req.open(method, url, true);
        req.withCredentials = !!options.withCredentials;
        for (key in _headers) {
          if (!__hasProp.call(_headers, key)) continue;
          value = _headers[key];
          req.setRequestHeader(key, value);
        }
        _headers = null;
        if (typeof options.progress === 'function') {
          req.upload.onprogress = function(event) {
            value = event.lengthComputable ? event.loaded * 100 / event.total : 0;
            return options.progress(Math.round(value));
          };
        }
        req.onreadystatechange = function() {
          if (req.readyState !== 4) {
            return;
          }
          if (_this._is_success(req.status)) {
            return resolve(_this._prepare_response(req));
          } else if (_this._is_app_error(req.status)) {
            return reject(Error(_this._prepare_error(req)));
          } else {
            return reject(Error('500 Internal Server Error'));
          }
        };
        req.onerror = function() {
          reject(Error("Network Error"));
        };
        return req.send(data);
      };
    })(this));
  };

  Net.upload = function(url, data, options, xhr) {
    var method;
    if (data == null) {
      data = {};
    }
    if (options == null) {
      options = {};
    }
    if (!this.XHR_UPLOAD) {
      throw Error('File upload not supported');
    }
    method = options.method || 'POST';
    options.json = false;
    return this.request(method, url, data, options, xhr);
  };

  Net.iframe_upload = function(form, url, data, options) {
    var as_json, method;
    if (data == null) {
      data = {};
    }
    if (options == null) {
      options = {};
    }
    as_json = options.as_json != null ? options.as_json : this.use_json;
    if (!(form instanceof pi.Nod)) {
      form = pi.Nod.create(form);
    }
    if (form == null) {
      throw Error('Form is undefined');
    }
    method = options.method || 'POST';
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return pi.net.IframeUpload.upload(form, url, _this._to_params(data), method).then(function(response) {
          var e;
          if (response == null) {
            reject(Error('Response is empty'));
          }
          if (!as_json) {
            resolve(response.innerHtml);
          }
          response = (function() {
            try {
              return JSON.parse(response.innerHTML);
            } catch (_error) {
              e = _error;
              return JSON.parse(response.innerText);
            }
          })();
          return resolve(response);
        })["catch"](function(e) {
          return reject(e);
        });
      };
    })(this));
  };

  return Net;

})();

pi.Net.XHR_UPLOAD = !!window.FormData;

pi.net = pi.Net;

_ref = ['get', 'post', 'patch', 'delete'];
for (_i = 0, _len = _ref.length; _i < _len; _i++) {
  method = _ref[_i];
  pi.net[method] = utils.curry(pi.net.request, [method.toUpperCase()], pi.net);
}



},{"../core":34}],52:[function(require,module,exports){
'use strict'
window.pi = require('./core')
require('./components')
require('./net')
require('./resources')
require('./controllers')
require('./views')
module.exports = window.pi
},{"./components":18,"./controllers":24,"./core":34,"./net":50,"./resources":70,"./views":78}],53:[function(require,module,exports){
'use strict';
require('./selectable');

require('./renderable');

require('./restful');



},{"./renderable":54,"./restful":55,"./selectable":56}],54:[function(require,module,exports){
'use strict';
var pi, utils, _renderer_reg,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

pi = require('../../core');

require('../../components/base');

require('../plugin');

utils = pi.utils;

_renderer_reg = /(\w+)(?:\(([\w\-\/]+)\))?/;

pi.Base.Renderable = (function(_super) {
  __extends(Renderable, _super);

  function Renderable() {
    return Renderable.__super__.constructor.apply(this, arguments);
  }

  Renderable.prototype.id = 'renderable';

  Renderable.included = function(klass) {
    var self;
    self = this;
    return klass.before_initialize(function() {
      return this.attach_plugin(self);
    });
  };

  Renderable.prototype.initialize = function(target) {
    this.target = target;
    Renderable.__super__.initialize.apply(this, arguments);
    this.target._renderer = this.find_renderer();
    this.target.delegate_to(this, 'render');
    return this;
  };

  Renderable.prototype.render = function(data) {
    var nod;
    this.target.remove_children();
    if (data != null) {
      nod = this.target._renderer.render(data, false);
      if (nod != null) {
        this.target.append(nod);
        this.target.piecify(this.target);
      } else {
        utils.error("failed to render data for: " + this.target.pid + "}", data);
      }
    }
    return this.target;
  };

  Renderable.prototype.find_renderer = function() {
    var klass, name, param, _, _ref;
    if ((this.target.options.renderer != null) && _renderer_reg.test(this.target.options.renderer)) {
      _ref = this.target.options.renderer.match(_renderer_reg), _ = _ref[0], name = _ref[1], param = _ref[2];
      klass = pi.Renderers[utils.camelCase(name)];
      if (klass != null) {
        return new klass(param);
      }
    }
    return new pi.Renderers.Base();
  };

  return Renderable;

})(pi.Plugin);



},{"../../components/base":5,"../../core":34,"../plugin":66}],55:[function(require,module,exports){
'use strict';
var pi, utils,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

pi = require('../../core');

require('../plugin');

require('../../components/base/base');

utils = pi.utils;

pi.Base.Restful = (function(_super) {
  __extends(Restful, _super);

  function Restful() {
    return Restful.__super__.constructor.apply(this, arguments);
  }

  Restful.prototype.id = 'restful';

  Restful.prototype.initialize = function(target) {
    var f, promise, rest;
    this.target = target;
    Restful.__super__.initialize.apply(this, arguments);
    this._uid = utils.uid('r');
    if (!this.target.has_renderable) {
      this.target.attach_plugin(pi.Base.Renderable);
    }
    if ((rest = this.target.options.rest) != null) {
      f = pi.Compiler.str_to_fun(rest);
      promise = f.call(this);
      if (!(promise instanceof Promise)) {
        promise = promise ? utils.promise.resolved_promise(promise) : utils.promise.rejected_promise();
      }
      promise.then((function(_this) {
        return function(resource) {
          return _this.bind(resource, _this.target.children().length === 0);
        };
      })(this), (function(_this) {
        return function() {
          return utils.error("resource not found: " + rest, _this.target.options.rest);
        };
      })(this));
    }
    return this;
  };

  Restful.prototype.bind = function(resource, render) {
    if (render == null) {
      render = false;
    }
    if (this.resource) {
      this.resource.off(pi.ResourceEvent.Update, this.resource_update());
      this.resource.off(pi.ResourceEvent.Create, this.resource_update());
    }
    this.resource = resource;
    if (!this.resource) {
      this.target.render(null);
      return;
    }
    this.resource.on([pi.ResourceEvent.Update, pi.ResourceEvent.Create], this.resource_update());
    if (render) {
      return this.target.render(resource);
    }
  };

  Restful.prototype.resource_update = function(e) {
    utils.debug_verbose('Restful component event', e);
    return this.on_update(e.currentTarget);
  };

  Restful.event_handler('resource_update');

  Restful.prototype.on_update = function(data) {
    return this.target.render(data);
  };

  Restful.prototype.dispose = function() {
    return this.bind(null);
  };

  return Restful;

})(pi.Plugin);



},{"../../components/base/base":2,"../../core":34,"../plugin":66}],56:[function(require,module,exports){
'use strict';
var pi, utils,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

pi = require('../../core');

require('../../components/base');

require('../plugin');

utils = pi.utils;

pi.Base.Selectable = (function(_super) {
  __extends(Selectable, _super);

  function Selectable() {
    return Selectable.__super__.constructor.apply(this, arguments);
  }

  Selectable.prototype.id = 'selectable';

  Selectable.prototype.initialize = function(target) {
    this.target = target;
    Selectable.__super__.initialize.apply(this, arguments);
    this.__selected__ = this.target.hasClass(pi.klass.SELECTED);
    this.target.on('click', this.click_handler());
    return this;
  };

  Selectable.prototype.click_handler = function(e) {
    if (!this.target.enabled) {
      return;
    }
    this.toggle_select();
    return false;
  };

  Selectable.event_handler('click_handler');

  Selectable.prototype.toggle_select = function() {
    if (this.__selected__) {
      return this.deselect();
    } else {
      return this.select();
    }
  };

  Selectable.prototype.select = function() {
    if (!this.__selected__) {
      this.__selected__ = true;
      this.target.addClass(pi.klass.SELECTED);
      this.target.trigger(pi.Events.Selected, true);
    }
    return this;
  };

  Selectable.prototype.deselect = function() {
    if (this.__selected__) {
      this.__selected__ = false;
      this.target.removeClass(pi.klass.SELECTED);
      this.target.trigger(pi.Events.Selected, false);
    }
    return this;
  };

  return Selectable;

})(pi.Plugin);



},{"../../components/base":5,"../../core":34,"../plugin":66}],57:[function(require,module,exports){
'use strict';
require('./plugin');

require('./base');

require('./list');



},{"./base":53,"./list":59,"./plugin":66}],58:[function(require,module,exports){
'use strict';
var pi, utils, _is_continuation,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

pi = require('../../core');

require('../../components/base/list');

require('../plugin');

utils = pi.utils;

_is_continuation = function(prev, params) {
  var key, val;
  for (key in prev) {
    if (!__hasProp.call(prev, key)) continue;
    val = prev[key];
    if (params[key] !== val) {
      return false;
    }
  }
  return true;
};

pi.List.Filterable = (function(_super) {
  __extends(Filterable, _super);

  function Filterable() {
    return Filterable.__super__.constructor.apply(this, arguments);
  }

  Filterable.prototype.id = 'filterable';

  Filterable.prototype.initialize = function(list) {
    this.list = list;
    Filterable.__super__.initialize.apply(this, arguments);
    this.list.delegate_to(this, 'filter');
    this.list.on(pi.ListEvent.Update, ((function(_this) {
      return function(e) {
        return _this.item_updated(e.data.item);
      };
    })(this)), this, (function(_this) {
      return function(e) {
        return (e.data.type === pi.ListEvent.ItemAdded || e.data.type === pi.ListEvent.ItemUpdated) && e.data.item.host === _this.list;
      };
    })(this));
    return this;
  };

  Filterable.prototype.item_updated = function(item) {
    if (!this.matcher) {
      return false;
    }
    if (this._all_items.indexOf(item) < 0) {
      this._all_items.unshift(item);
    }
    if (this.matcher(item)) {
      return;
    } else if (this.filtered) {
      this.list.remove_item(item, true, false);
    }
    return false;
  };

  Filterable.prototype.all_items = function() {
    return this._all_items.filter(function(item) {
      return !item._disposed;
    });
  };

  Filterable.prototype.start_filter = function() {
    if (this.filtered) {
      return;
    }
    this.filtered = true;
    this.list.addClass(pi.klass.FILTERED);
    this._all_items = this.list.items.slice();
    return this._prevf = {};
  };

  Filterable.prototype.stop_filter = function(rollback) {
    if (rollback == null) {
      rollback = true;
    }
    if (!this.filtered) {
      return;
    }
    this.filtered = false;
    this.list.removeClass(pi.klass.FILTERED);
    if (rollback) {
      this.list.data_provider(this.all_items(), false, false);
    }
    this._all_items = null;
    this.matcher = null;
    return this.list.trigger(pi.ListEvent.Filtered, false);
  };

  Filterable.prototype.filter = function(params) {
    var item, scope, _buffer;
    if (params == null) {
      return this.stop_filter();
    }
    if (!this.filtered) {
      this.start_filter();
    }
    scope = _is_continuation(this._prevf, params) ? this.list.items.slice() : this.all_items();
    this._prevf = params;
    this.matcher = utils.matchers.object_ext({
      record: params
    });
    _buffer = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = scope.length; _i < _len; _i++) {
        item = scope[_i];
        if (this.matcher(item)) {
          _results.push(item);
        }
      }
      return _results;
    }).call(this);
    this.list.data_provider(_buffer, false, false);
    return this.list.trigger(pi.ListEvent.Filtered, true);
  };

  return Filterable;

})(pi.Plugin);



},{"../../components/base/list":8,"../../core":34,"../plugin":66}],59:[function(require,module,exports){
'use strict';
require('./selectable');

require('./sortable');

require('./searchable');

require('./filterable');

require('./scrollend');

require('./nested_select');

require('./restful');



},{"./filterable":58,"./nested_select":60,"./restful":61,"./scrollend":62,"./searchable":63,"./selectable":64,"./sortable":65}],60:[function(require,module,exports){
'use strict';
var pi, utils, _null,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

pi = require('../../core');

require('../../components/base/list');

require('../plugin');

require('./selectable');

utils = pi.utils;

_null = function() {};

pi.List.NestedSelect = (function(_super) {
  __extends(NestedSelect, _super);

  function NestedSelect() {
    return NestedSelect.__super__.constructor.apply(this, arguments);
  }

  NestedSelect.prototype.id = 'nested_select';

  NestedSelect.prototype.initialize = function(list) {
    this.list = list;
    pi.Plugin.prototype.initialize.apply(this, arguments);
    this.nested_klass = this.list.options.nested_klass || 'nested-list';
    this.selectable = this.list.selectable || {
      select_all: _null,
      clear_selection: _null,
      type: _null,
      _selected_item: null,
      enable: _null,
      disable: _null
    };
    this.list.delegate_to(this, 'clear_selection', 'select_all', 'selected', 'where', 'select_item', 'deselect_item');
    if (this.list.has_selectable !== true) {
      this.list.delegate_to(this, 'selected_records', 'selected_record', 'selected_item', 'selected_size');
    }
    this.enabled = true;
    if (this.list.options.no_select != null) {
      this.disable();
    }
    this.type(this.list.options.nested_select_type || "");
    this.list.on([pi.Events.Selected, pi.Events.SelectionCleared], (function(_this) {
      return function(e) {
        var item;
        if (_this._watching_radio && e.type === pi.Events.Selected) {
          if (e.target === _this.list) {
            item = _this.selectable._selected_item;
          } else {
            item = e.data[0].host.selectable._selected_item;
          }
          _this.update_radio_selection(item);
        }
        if (e.target !== _this.list) {
          e.cancel();
          return _this._check_selected();
        } else {
          return false;
        }
      };
    })(this));
    return this;
  };

  NestedSelect.prototype.enable = function() {
    var item, _i, _len, _ref, _ref1, _results;
    if (!this.enabled) {
      this.enabled = true;
      this.selectable.enable();
      _ref = this.list.find_cut("." + this.nested_klass);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        item = _ref[_i];
        _results.push((_ref1 = item._nod.selectable) != null ? _ref1.enable() : void 0);
      }
      return _results;
    }
  };

  NestedSelect.prototype.disable = function() {
    var item, _i, _len, _ref, _ref1, _results;
    if (this.enabled) {
      this.enabled = false;
      this.selectable.disable();
      _ref = this.list.find_cut("." + this.nested_klass);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        item = _ref[_i];
        _results.push((_ref1 = item._nod.selectable) != null ? _ref1.disable() : void 0);
      }
      return _results;
    }
  };

  NestedSelect.prototype.select_item = function(item, force) {
    var _ref;
    if (force == null) {
      force = false;
    }
    if (!item.__selected__) {
      if (this._watching_radio) {
        this.clear_selection(true);
      }
      if ((_ref = item.host.selectable) != null) {
        if (typeof _ref.select_item === "function") {
          _ref.select_item(item, force);
        }
      }
      this._check_selected();
      return item;
    }
  };

  NestedSelect.prototype.deselect_item = function(item, force) {
    var _ref;
    if (force == null) {
      force = false;
    }
    if (item.__selected__) {
      if ((_ref = item.host.selectable) != null) {
        if (typeof _ref.deselect_item === "function") {
          _ref.deselect_item(item, force);
        }
      }
      this._check_selected();
      return item;
    }
  };

  NestedSelect.prototype.where = function(query) {
    var item, ref, _i, _len, _ref;
    ref = pi.List.prototype.where.call(this.list, query);
    _ref = this.list.find_cut("." + this.nested_klass);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      item = _ref[_i];
      ref = ref.concat(item._nod.where(query));
    }
    return ref;
  };

  NestedSelect.prototype.type = function(value) {
    this.is_radio = !!value.match('radio');
    if (this.is_radio) {
      return this.enable_radio_watch();
    } else {
      return this.disable_radio_watch();
    }
  };

  NestedSelect.prototype.enable_radio_watch = function() {
    return this._watching_radio = true;
  };

  NestedSelect.prototype.disable_radio_watch = function() {
    return this._watching_radio = false;
  };

  NestedSelect.prototype.update_radio_selection = function(item) {
    if (!item || (this._prev_selected_list === item.host)) {
      return;
    }
    this._prev_selected_list = item.host;
    if (this.list.selected().length > 1) {
      this.list.clear_selection(true);
      item.host.select_item(item);
    }
  };

  NestedSelect.prototype.clear_selection = function(silent, force) {
    var item, _base, _i, _len, _ref;
    if (silent == null) {
      silent = false;
    }
    if (force == null) {
      force = false;
    }
    this.selectable.clear_selection(silent, force);
    _ref = this.list.find_cut("." + this.nested_klass);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      item = _ref[_i];
      if (typeof (_base = item._nod).clear_selection === "function") {
        _base.clear_selection(silent);
      }
    }
    if (!silent) {
      return this.list.trigger(pi.Events.SelectionCleared);
    }
  };

  NestedSelect.prototype.select_all = function(silent, force) {
    var item, _base, _i, _len, _ref, _selected;
    if (silent == null) {
      silent = false;
    }
    if (force == null) {
      force = false;
    }
    this.selectable.select_all(true, force);
    _ref = this.list.find_cut("." + this.nested_klass);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      item = _ref[_i];
      if (typeof (_base = item._nod).select_all === "function") {
        _base.select_all(true, force);
      }
    }
    if (!silent) {
      _selected = this.selected();
      if (_selected.length) {
        return this.list.trigger(pi.Events.Selected, _selected);
      }
    }
  };

  NestedSelect.prototype.selected = function() {
    var item, sublist, _i, _len, _ref, _selected;
    _selected = [];
    _ref = this.list.items;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      item = _ref[_i];
      if (item.__selected__) {
        _selected.push(item);
      }
      if (item instanceof pi.List) {
        _selected = _selected.concat((typeof item.selected === "function" ? item.selected() : void 0) || []);
      } else if ((sublist = item.find("." + this.nested_klass))) {
        _selected = _selected.concat((typeof sublist.selected === "function" ? sublist.selected() : void 0) || []);
      }
    }
    return _selected;
  };

  return NestedSelect;

})(pi.List.Selectable);



},{"../../components/base/list":8,"../../core":34,"../plugin":66,"./selectable":64}],61:[function(require,module,exports){
'use strict';
var pi, utils,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

pi = require('../../core');

require('../plugin');

require('../../components/base/list');

utils = pi.utils;

pi.List.Restful = (function(_super) {
  __extends(Restful, _super);

  function Restful() {
    return Restful.__super__.constructor.apply(this, arguments);
  }

  Restful.prototype.id = 'restful';

  Restful.prototype.initialize = function(list) {
    var resources, rest;
    this.list = list;
    Restful.__super__.initialize.apply(this, arguments);
    this.items_by_id = {};
    this.listen_load = this.list.options.listen_load === true;
    this.listen_create = this.list.options.listen_create != null ? this.list.options.listen_create : this.listen_load;
    if ((rest = this.list.options.rest) != null) {
      if (!(rest.indexOf(".") > 0)) {
        rest = utils.camelCase(rest);
      }
      resources = pi.Compiler.str_to_fun(rest).call();
    }
    if (resources != null) {
      this.bind(resources, this.list.options.load_rest, this.scope);
    }
    this.list.delegate_to(this, 'find_by_id');
    this.list.on(pi.Events.Destroyed, (function(_this) {
      return function() {
        _this.bind(null);
        return false;
      };
    })(this));
    return this;
  };

  Restful.prototype.bind = function(resources, load) {
    if (load == null) {
      load = false;
    }
    if (this.resources) {
      this.resources.off(this.resource_update());
    }
    this.resources = resources;
    if (this.resources == null) {
      this.items_by_id = {};
      if (!this.list._disposed) {
        this.list.clear();
      }
      return;
    }
    this.resources.listen(this.resource_update());
    if (load) {
      return this.load(resources.all());
    }
  };

  Restful.prototype.find_by_id = function(id) {
    var items;
    if (this.listen_load) {
      if (this.items_by_id[id] != null) {
        return this.items_by_id[id];
      }
    }
    items = this.list.where({
      record: {
        id: id | 0
      }
    });
    if (items.length) {
      return this.items_by_id[id] = items[0];
    }
  };

  Restful.prototype.load = function(data) {
    var item, _i, _len;
    for (_i = 0, _len = data.length; _i < _len; _i++) {
      item = data[_i];
      if (!(this.items_by_id[item.id] && this.listen_load)) {
        this.items_by_id[item.id] = this.list.add_item(item, true);
      }
    }
    return this.list.update();
  };

  Restful.prototype.resource_update = function(e) {
    var _ref;
    utils.debug_verbose('Restful list event', e);
    return (_ref = this["on_" + e.data.type]) != null ? _ref.call(this, e.data[this.resources.resource_name]) : void 0;
  };

  Restful.event_handler('resource_update');

  Restful.prototype.on_load = function() {
    if (!this.listen_load) {
      return;
    }
    return this.load(this.resources.all());
  };

  Restful.prototype.on_create = function(data) {
    var item;
    if (!this.listen_create) {
      return;
    }
    if (!this.find_by_id(data.id)) {
      return this.items_by_id[data.id] = this.list.add_item(data);
    } else if (data.__tid__ && (item = this.find_by_id(data.__tid__))) {
      delete this.items_by_id[data.__tid__];
      this.items_by_id[data.id] = item;
      return this.list.update_item(item, data);
    }
  };

  Restful.prototype.on_destroy = function(data) {
    var item;
    if ((item = this.find_by_id(data.id))) {
      this.list.remove_item(item);
      delete this.items_by_id[data.id];
    }
  };

  Restful.prototype.on_update = function(data) {
    var item;
    if ((item = this.find_by_id(data.id))) {
      return this.list.update_item(item, data);
    }
  };

  Restful.prototype.dispose = function() {
    this.items_by_id = {};
    if (this.resources != null) {
      return this.resources.off(this.resource_update());
    }
  };

  return Restful;

})(pi.Plugin);



},{"../../components/base/list":8,"../../core":34,"../plugin":66}],62:[function(require,module,exports){
'use strict';
var pi, utils,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

pi = require('../../core');

require('../../components/base/list');

require('../plugin');

utils = pi.utils;

pi.List.ScrollEnd = (function(_super) {
  __extends(ScrollEnd, _super);

  function ScrollEnd() {
    return ScrollEnd.__super__.constructor.apply(this, arguments);
  }

  ScrollEnd.prototype.id = 'scroll_end';

  ScrollEnd.prototype.initialize = function(list) {
    this.list = list;
    ScrollEnd.__super__.initialize.apply(this, arguments);
    this.scroll_object = this.list.options.scroll_object === 'window' ? pi.Nod.win : this.list.options.scroll_object ? pi.$(this.list.options.scroll_object) : this.list.items_cont;
    this._prev_top = this.scroll_object.scrollTop();
    if (this.list.options.scroll_end !== false) {
      this.enable();
    }
    this.list.on(pi.ListEvent.Update, this.scroll_listener(), this, (function(_this) {
      return function(e) {
        return _this.enabled && (e.data.type === pi.ListEvent.ItemRemoved || e.data.type === pi.ListEvent.Load);
      };
    })(this));
    return this;
  };

  ScrollEnd.prototype.enable = function() {
    if (this.enabled) {
      return;
    }
    this.scroll_object.on('scroll', this.scroll_listener());
    return this.enabled = true;
  };

  ScrollEnd.prototype.disable = function() {
    if (!this.enabled) {
      return;
    }
    this.__debounce_id__ && clearTimeout(this.__debounce_id__);
    if (this.scroll_object._disposed !== true) {
      this.scroll_object.off('scroll', this.scroll_listener());
    }
    this._scroll_listener = null;
    return this.enabled = false;
  };

  ScrollEnd.prototype.scroll_listener = function(event) {
    if (this.list._disposed) {
      return false;
    }
    if (this._prev_top <= this.scroll_object.scrollTop() && this.list.height() - this.scroll_object.scrollTop() - this.scroll_object.height() < 50) {
      this.list.trigger(pi.ListEvent.ScrollEnd);
    }
    this._prev_top = this.scroll_object.scrollTop();
    return false;
  };

  ScrollEnd.event_handler('scroll_listener', {
    throttle: 500
  });

  ScrollEnd.prototype.dispose = function() {
    return this.disable();
  };

  return ScrollEnd;

})(pi.Plugin);



},{"../../components/base/list":8,"../../core":34,"../plugin":66}],63:[function(require,module,exports){
'use strict';
var pi, utils, _clear_mark_regexp, _is_continuation, _selector_regexp,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

pi = require('../../core');

require('../../components/base/list');

require('../plugin');

utils = pi.utils;

_clear_mark_regexp = /<mark>([^<>]*)<\/mark>/gim;

_selector_regexp = /[\.#a-z\s\[\]=\"-_,]/i;

_is_continuation = function(prev, query) {
  var _ref;
  return ((_ref = query.match(prev)) != null ? _ref.index : void 0) === 0;
};

pi.List.Searchable = (function(_super) {
  __extends(Searchable, _super);

  function Searchable() {
    return Searchable.__super__.constructor.apply(this, arguments);
  }

  Searchable.prototype.id = 'searchable';

  Searchable.prototype.initialize = function(list) {
    this.list = list;
    Searchable.__super__.initialize.apply(this, arguments);
    this.update_scope(this.list.options.search_scope);
    this.list.delegate_to(this, 'search', 'highlight');
    this.searching = false;
    this.list.on(pi.ListEvent.Update, ((function(_this) {
      return function(e) {
        return _this.item_updated(e.data.item);
      };
    })(this)), this, (function(_this) {
      return function(e) {
        return (e.data.type === pi.ListEvent.ItemAdded || e.data.type === pi.ListEvent.ItemUpdated) && e.data.item.host === _this.list;
      };
    })(this));
    return this;
  };

  Searchable.prototype.item_updated = function(item) {
    if (!this.matcher) {
      return false;
    }
    if (this._all_items.indexOf(item) < 0) {
      this._all_items.unshift(item);
    }
    if (this.matcher(item)) {
      this.highlight_item(this._prevq, item);
      return;
    } else if (this.searching) {
      this.list.remove_item(item, true, false);
    }
    return false;
  };

  Searchable.prototype.update_scope = function(scope) {
    this.matcher_factory = this._matcher_from_scope(scope);
    if (scope && _selector_regexp.test(scope)) {
      return this._highlight_elements = function(item) {
        var selector, _i, _len, _ref, _results;
        _ref = scope.split(',');
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          selector = _ref[_i];
          _results.push(item.find(selector));
        }
        return _results;
      };
    } else {
      return this._highlight_elements = function(item) {
        return [item];
      };
    }
  };

  Searchable.prototype._matcher_from_scope = function(scope) {
    return this.matcher_factory = scope == null ? function(value) {
      return utils.matchers.nod(value);
    } : function(value) {
      return utils.matchers.nod(scope + ':' + value);
    };
  };

  Searchable.prototype.all_items = function() {
    return this._all_items.filter(function(item) {
      return !item._disposed;
    });
  };

  Searchable.prototype.start_search = function() {
    if (this.searching) {
      return;
    }
    this.searching = true;
    this.list.addClass(pi.klass.SEARCHING);
    this._all_items = this.list.items.slice();
    return this._prevq = '';
  };

  Searchable.prototype.stop_search = function(rollback) {
    var items;
    if (rollback == null) {
      rollback = true;
    }
    if (!this.searching) {
      return;
    }
    this.searching = false;
    this.list.removeClass(pi.klass.SEARCHING);
    items = this.all_items();
    this.clear_highlight(items);
    if (rollback) {
      this.list.data_provider(items, false, false);
    }
    this._all_items = null;
    this.matcher = null;
    return this.list.trigger(pi.ListEvent.Searched, false);
  };

  Searchable.prototype.clear_highlight = function(nodes) {
    var nod, _i, _len, _raw_html, _results;
    _results = [];
    for (_i = 0, _len = nodes.length; _i < _len; _i++) {
      nod = nodes[_i];
      _raw_html = nod.html();
      _raw_html = _raw_html.replace(_clear_mark_regexp, "$1");
      _results.push(nod.html(_raw_html));
    }
    return _results;
  };

  Searchable.prototype.highlight_item = function(query, item) {
    var nod, nodes, _i, _len, _raw_html, _regexp, _results;
    nodes = this._highlight_elements(item);
    _results = [];
    for (_i = 0, _len = nodes.length; _i < _len; _i++) {
      nod = nodes[_i];
      if (!(nod != null)) {
        continue;
      }
      _raw_html = nod.html();
      _regexp = new RegExp("((?:^|>)[^<>]*?)(" + query + ")", "gim");
      _raw_html = _raw_html.replace(_clear_mark_regexp, "$1");
      if (query !== '') {
        _raw_html = _raw_html.replace(_regexp, '$1<mark>$2</mark>');
      }
      _results.push(nod.html(_raw_html));
    }
    return _results;
  };

  Searchable.prototype.highlight = function(q) {
    var item, _i, _len, _ref;
    this._prevq = q;
    _ref = this.list.items;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      item = _ref[_i];
      this.highlight_item(q, item);
    }
  };

  Searchable.prototype.search = function(q, highlight) {
    var item, scope, _buffer;
    if (q == null) {
      q = '';
    }
    if (q === '') {
      return this.stop_search();
    }
    if (highlight == null) {
      highlight = this.list.options.highlight;
    }
    if (!this.searching) {
      this.start_search();
    }
    scope = _is_continuation(this._prevq, q) ? this.list.items.slice() : this.all_items();
    this._prevq = q;
    this.matcher = this.matcher_factory(utils.escapeRegexp(q));
    _buffer = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = scope.length; _i < _len; _i++) {
        item = scope[_i];
        if (this.matcher(item)) {
          _results.push(item);
        }
      }
      return _results;
    }).call(this);
    this.list.data_provider(_buffer, false, false);
    if (highlight) {
      this.highlight(q);
    }
    return this.list.trigger(pi.ListEvent.Searched, true);
  };

  return Searchable;

})(pi.Plugin);



},{"../../components/base/list":8,"../../core":34,"../plugin":66}],64:[function(require,module,exports){
'use strict';
var pi, utils,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

pi = require('../../core');

require('../../components/base/list');

require('../plugin');

utils = pi.utils;

pi.List.Selectable = (function(_super) {
  __extends(Selectable, _super);

  function Selectable() {
    return Selectable.__super__.constructor.apply(this, arguments);
  }

  Selectable.prototype.id = 'selectable';

  Selectable.prototype.initialize = function(list) {
    var item, _i, _len, _ref;
    this.list = list;
    Selectable.__super__.initialize.apply(this, arguments);
    this.list.merge_classes.push(pi.klass.SELECTED);
    this.type(this.list.options.select_type || 'radio');
    if (this.list.options.no_select == null) {
      this.enable();
    }
    _ref = this.list.items;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      item = _ref[_i];
      if (item.hasClass(pi.klass.SELECTED)) {
        item.__selected__ = true;
      }
    }
    this.list.delegate_to(this, 'clear_selection', 'selected', 'selected_item', 'select_all', 'select_item', 'selected_records', 'selected_record', 'deselect_item', 'toggle_select', 'selected_size');
    this.list.on(pi.ListEvent.Update, ((function(_this) {
      return function(e) {
        _this._selected = null;
        _this._check_selected();
        return false;
      };
    })(this)), this, function(e) {
      return e.data.type !== pi.ListEvent.ItemAdded;
    });
    return this;
  };

  Selectable.prototype.enable = function() {
    if (!this.enabled) {
      this.enabled = true;
      return this.list.on(pi.ListEvent.ItemClick, this.item_click_handler());
    }
  };

  Selectable.prototype.disable = function() {
    if (this.enabled) {
      this.enabled = false;
      return this.list.off(pi.ListEvent.ItemClick, this.item_click_handler());
    }
  };

  Selectable.prototype.type = function(value) {
    this.is_radio = !!value.match('radio');
    return this.is_check = !!value.match('check');
  };

  Selectable.prototype.item_click_handler = function(e) {
    this.list.toggle_select(e.data.item, true);
    if (e.data.item.enabled) {
      this._check_selected();
    }
  };

  Selectable.event_handler('item_click_handler');

  Selectable.prototype._check_selected = function() {
    if (this.list.selected().length) {
      return this.list.trigger(pi.Events.Selected, this.list.selected());
    } else {
      return this.list.trigger(pi.Events.SelectionCleared);
    }
  };

  Selectable.prototype.select_item = function(item, force) {
    if (force == null) {
      force = false;
    }
    if (!item.__selected__ && (item.enabled || !force)) {
      if (this.is_radio && force) {
        this.clear_selection(true);
      }
      item.__selected__ = true;
      this._selected_item = item;
      this._selected = null;
      return item.addClass(pi.klass.SELECTED);
    }
  };

  Selectable.prototype.deselect_item = function(item, force) {
    if (force == null) {
      force = false;
    }
    if (item.__selected__ && ((item.enabled && this.is_check) || (!force))) {
      item.__selected__ = false;
      this._selected = null;
      if (this._selected_item === item) {
        this._selected_item = null;
      }
      return item.removeClass(pi.klass.SELECTED);
    }
  };

  Selectable.prototype.toggle_select = function(item, force) {
    if (item.__selected__) {
      return this.deselect_item(item, force);
    } else {
      return this.select_item(item, force);
    }
  };

  Selectable.prototype.clear_selection = function(silent, force) {
    var item, _i, _len, _ref;
    if (silent == null) {
      silent = false;
    }
    if (force == null) {
      force = false;
    }
    _ref = this.list.items;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      item = _ref[_i];
      if (item.enabled || force) {
        this.deselect_item(item);
      }
    }
    if (!silent) {
      return this.list.trigger(pi.Events.SelectionCleared);
    }
  };

  Selectable.prototype.select_all = function(silent, force) {
    var item, _i, _len, _ref;
    if (silent == null) {
      silent = false;
    }
    if (force == null) {
      force = false;
    }
    _ref = this.list.items;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      item = _ref[_i];
      if (item.enabled || force) {
        this.select_item(item);
      }
    }
    if (this.selected().length && !silent) {
      return this.list.trigger(pi.Events.Selected, this.selected());
    }
  };

  Selectable.prototype.selected = function() {
    if (this._selected == null) {
      this._selected = this.list.where({
        __selected__: true
      });
    }
    return this._selected;
  };

  Selectable.prototype.selected_item = function() {
    var _ref;
    _ref = this.list.selected();
    if (_ref.length) {
      return _ref[0];
    } else {
      return null;
    }
  };

  Selectable.prototype.selected_records = function() {
    return this.list.selected().map(function(item) {
      return item.record;
    });
  };

  Selectable.prototype.selected_record = function() {
    var _ref;
    _ref = this.list.selected_records();
    if (_ref.length) {
      return _ref[0];
    } else {
      return null;
    }
  };

  Selectable.prototype.selected_size = function() {
    return this.list.selected().length;
  };

  return Selectable;

})(pi.Plugin);



},{"../../components/base/list":8,"../../core":34,"../plugin":66}],65:[function(require,module,exports){
'use strict';
var pi, utils,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

pi = require('../../core');

require('../../components/base/list');

require('../plugin');

utils = pi.utils;

pi.List.Sortable = (function(_super) {
  __extends(Sortable, _super);

  function Sortable() {
    return Sortable.__super__.constructor.apply(this, arguments);
  }

  Sortable.prototype.id = 'sortable';

  Sortable.prototype.initialize = function(list) {
    var param, _fn, _i, _len, _ref;
    this.list = list;
    Sortable.__super__.initialize.apply(this, arguments);
    if (this.list.options.sort != null) {
      this._prevs = [];
      _ref = this.list.options.sort.split(",");
      _fn = (function(_this) {
        return function(param) {
          var data, key, order, _ref1;
          data = {};
          _ref1 = param.split(":"), key = _ref1[0], order = _ref1[1];
          data[key] = order;
          return _this._prevs.push(data);
        };
      })(this);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        param = _ref[_i];
        _fn(param);
      }
      this._compare_fun = function(a, b) {
        return utils.keys_compare(a.record, b.record, this._prevs);
      };
    }
    this.list.delegate_to(this, 'sort');
    this.list.on(pi.ListEvent.Update, ((function(_this) {
      return function(e) {
        return _this.item_updated(e.data.item);
      };
    })(this)), this, (function(_this) {
      return function(e) {
        return (e.data.type === pi.ListEvent.ItemAdded || e.data.type === pi.ListEvent.ItemUpdated) && e.data.item.host === _this.list;
      };
    })(this));
    return this;
  };

  Sortable.prototype.item_updated = function(item) {
    if (!this._compare_fun) {
      return false;
    }
    this._bisect_sort(item, 0, this.list.size() - 1);
    return false;
  };

  Sortable.prototype._bisect_sort = function(item, left, right) {
    var a, i;
    if (right - left < 2) {
      if (this._compare_fun(item, this.list.items[left]) > 0) {
        this.list.move_item(item, right);
      } else {
        this.list.move_item(item, left);
      }
      return;
    }
    i = (left + (right - left) / 2) | 0;
    a = this.list.items[i];
    if (this._compare_fun(item, a) > 0) {
      left = i;
    } else {
      right = i;
    }
    return this._bisect_sort(item, left, right);
  };

  Sortable.prototype.sort = function(sort_params) {
    if (sort_params == null) {
      return;
    }
    sort_params = utils.to_a(sort_params);
    this._prevs = sort_params;
    this._compare_fun = function(a, b) {
      return utils.keys_compare(a.record, b.record, sort_params);
    };
    this.list.items.sort(this._compare_fun);
    this.list.data_provider(this.list.items.slice(), false, false);
    return this.list.trigger(pi.ListEvent.Sorted, sort_params);
  };

  Sortable.prototype.sorted = function(sort_params) {
    if (sort_params == null) {
      return;
    }
    sort_params = utils.to_a(sort_params);
    this._prevs = sort_params;
    this._compare_fun = function(a, b) {
      return utils.keys_compare(a.record, b.record, sort_params);
    };
    return this.list.trigger(pi.ListEvent.Sorted, sort_params);
  };

  return Sortable;

})(pi.Plugin);



},{"../../components/base/list":8,"../../core":34,"../plugin":66}],66:[function(require,module,exports){
'use strict';
var pi, utils,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

pi = require('../core');

utils = pi.utils;

pi.Plugin = (function(_super) {
  __extends(Plugin, _super);

  function Plugin() {
    return Plugin.__super__.constructor.apply(this, arguments);
  }

  Plugin.prototype.id = "";

  Plugin.included = function(klass) {
    var self;
    self = this;
    return klass.after_initialize(function() {
      return this.attach_plugin(self);
    });
  };

  Plugin.attached = function(instance) {
    return (new this()).initialize(instance);
  };

  Plugin.prototype.initialize = function(instance) {
    instance[this.id] = this;
    instance["has_" + this.id] = true;
    instance.addClass("has-" + this.id);
    return this;
  };

  Plugin.prototype.dispose = function() {
    return true;
  };

  return Plugin;

})(pi.Core);



},{"../core":34}],67:[function(require,module,exports){
'use strict';
var pi, utils,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

pi = require('../core');

require('./base');

require('./view');

utils = pi.utils;

pi.resources.Association = (function(_super) {
  __extends(Association, _super);

  function Association(resources, scope, options) {
    this.resources = resources;
    this.options = options != null ? options : {};
    Association.__super__.constructor.apply(this, arguments);
    this._only_update = false;
    this.owner = this.options.owner;
    if (options.belongs_to === true) {
      if (options.owner._persisted) {
        this.owner_name_id = this.options.key;
      } else {
        this._only_update = true;
        this.options.owner.one(pi.ResourceEvent.Create, ((function(_this) {
          return function() {
            var el, _i, _len, _ref, _ref1;
            _this._only_update = false;
            _this.owner = _this.options.owner;
            _this.owner_name_id = _this.options.key;
            _ref = _this.__all__;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              el = _ref[_i];
              el.set(utils.obj.wrap(_this.owner_name_id, _this.owner.id), true);
            }
            if (_this.options._scope !== false) {
              if (((_ref1 = _this.options._scope) != null ? _ref1[_this.options.key] : void 0) != null) {
                _this.options.scope = utils.merge(_this.options._scope, utils.obj.wrap(_this.options.key, _this.owner.id));
              } else {
                _this.options.scope = utils.obj.wrap(_this.options.key, _this.owner.id);
              }
              return _this.reload();
            }
          };
        })(this)));
      }
    } else {
      if (!this.options.scope) {
        this._only_update = true;
      }
    }
  }

  Association.prototype.clear_all = function() {
    if (this.options.route) {
      this.owner["" + this.options.name + "_loaded"] = false;
    }
    return Association.__super__.clear_all.apply(this, arguments);
  };

  Association.prototype.reload = function() {
    this.clear_all();
    if (this.options.scope) {
      this._filter = utils.matchers.object_ext(this.options.scope);
      return this.load(this.options.source.where(this.options.scope));
    }
  };

  Association.prototype.build = function(data, silent, params) {
    if (data == null) {
      data = {};
    }
    if (silent == null) {
      silent = false;
    }
    if (params == null) {
      params = {};
    }
    if (this.options.belongs_to === true) {
      if (data[this.owner_name_id] == null) {
        data[this.owner_name_id] = this.owner.id;
      }
      if (!(data instanceof pi.resources.Base)) {
        data = this.resources.build(data, false);
      }
    }
    return Association.__super__.build.call(this, data, silent, params);
  };

  Association.prototype.on_update = function(el) {
    if (this.get(el.id)) {
      if (this.options.copy === false) {
        return this.trigger(pi.ResourceEvent.Update, this._wrap(el));
      } else {
        return Association.__super__.on_update.apply(this, arguments);
      }
    } else if (this._only_update === false) {
      return this.build(el);
    }
  };

  Association.prototype.on_destroy = function(el) {
    if (this.options.copy === false) {
      this.trigger(pi.ResourceEvent.Destroy, this._wrap(el));
      return this.remove(el, true, false);
    } else {
      return Association.__super__.on_destroy.apply(this, arguments);
    }
  };

  Association.prototype.on_create = function(el) {
    var view_item;
    if ((view_item = this.get(el.id) || this.get(el.__tid__))) {
      this.created(view_item, el.__tid__);
      if (this.options.copy === false) {
        return this.trigger(pi.ResourceEvent.Create, this._wrap(el));
      } else {
        return view_item.set(el.attributes());
      }
    } else if (!this._only_update) {
      return this.build(el);
    }
  };

  Association.prototype.on_load = function() {
    if (this._only_update) {
      return;
    }
    if (this.options.scope) {
      this.load(this.resources.where(this.options.scope));
      return this.trigger(pi.ResourceEvent.Load, {});
    }
  };

  return Association;

})(pi.resources.View);



},{"../core":34,"./base":68,"./view":76}],68:[function(require,module,exports){
'use strict';
var pi, utils, _singular,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

pi = require('../core');

require('./events');

utils = pi.utils;

pi.resources = {};

pi["export"](pi.resources, "$r");

_singular = function(str) {
  return str.replace(/s$/, '');
};

pi.resources.Base = (function(_super) {
  __extends(Base, _super);

  Base.set_resource = function(plural, singular) {
    this.__all_by_id__ = {};
    this.__all_by_tid__ = {};
    this.__all__ = [];
    this.resources_name = plural;
    return this.resource_name = singular || _singular(plural);
  };

  Base.register_association = function(name) {
    if (this.prototype.__associations__ != null) {
      this.prototype.__associations__ = this.prototype.__associations__.slice();
    } else {
      this.prototype.__associations__ = [];
    }
    return this.prototype.__associations__.push(name);
  };

  Base.load = function(data, silent) {
    var el, elements;
    if (silent == null) {
      silent = false;
    }
    if (data != null) {
      elements = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = data.length; _i < _len; _i++) {
          el = data[_i];
          _results.push(this.build(el, true));
        }
        return _results;
      }).call(this);
      if (!silent) {
        this.trigger(pi.ResourceEvent.Load, {});
      }
      return elements;
    }
  };

  Base.from_data = function(data) {
    if (data[this.resource_name] != null) {
      data[this.resource_name] = this.build(data[this.resource_name]);
    }
    if (data[this.resources_name] != null) {
      return data[this.resources_name] = this.load(data[this.resources_name]);
    }
  };

  Base.clear_all = function() {
    var el, _i, _len, _ref;
    _ref = this.__all__;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      el = _ref[_i];
      el.dispose();
    }
    this.__all_by_id__ = {};
    this.__all_by_tid__ = {};
    return this.__all__.length = 0;
  };

  Base.get = function(id) {
    return this.__all_by_id__[id] || this.__all_by_tid__[id];
  };

  Base.get_by = function(params) {
    var ref;
    if (params == null) {
      return;
    }
    ref = this.where(params);
    if (ref.length) {
      return ref[0];
    } else {
      return null;
    }
  };

  Base.add = function(el) {
    if (this.get(el.id)) {
      return;
    }
    if (el.__temp__ === true) {
      this.__all_by_tid__[el.id] = el;
    } else {
      this.__all_by_id__[el.id] = el;
    }
    return this.__all__.push(el);
  };

  Base.build = function(data, silent, add) {
    var el;
    if (data == null) {
      data = {};
    }
    if (silent == null) {
      silent = false;
    }
    if (add == null) {
      add = true;
    }
    if (!(data.id && (el = this.get(data.id)))) {
      if (!data.id) {
        data.id = "tid_" + (utils.uid());
        data.__temp__ = true;
      }
      el = new this(data);
      if (add) {
        this.add(el);
        if (!(silent || el.__temp__)) {
          this.trigger(pi.ResourceEvent.Create, this._wrap(el));
        }
      }
      return el;
    } else {
      return el.set(data, silent);
    }
  };

  Base.created = function(el, temp_id) {
    if (this.__all_by_tid__[temp_id]) {
      delete this.__all_by_tid__[temp_id];
      return this.__all_by_id__[el.id] = el;
    }
  };

  Base.clear_temp = function(silent) {
    var el, _, _ref;
    if (silent == null) {
      silent = false;
    }
    _ref = this.__all_by_tid__;
    for (_ in _ref) {
      if (!__hasProp.call(_ref, _)) continue;
      el = _ref[_];
      this.remove(el, silent);
    }
    return this.__all_by_tid__ = {};
  };

  Base.remove_by_id = function(id, silent) {
    var el;
    el = this.get(id);
    if (el != null) {
      this.remove(el);
    }
    return false;
  };

  Base.remove = function(el, silent, disposed) {
    if (disposed == null) {
      disposed = true;
    }
    if (this.__all_by_id__[el.id] != null) {
      delete this.__all_by_id__[el.id];
    } else {
      delete this.__all_by_tid__[el.id];
    }
    this.__all__.splice(this.__all__.indexOf(el), 1);
    if (!silent) {
      this.trigger(pi.ResourceEvent.Destroy, this._wrap(el));
    }
    if (disposed) {
      el.dispose();
    }
    return true;
  };

  Base.listen = function(callback, filter) {
    return pi.event.on("" + this.resources_name + "_update", callback, null, filter);
  };

  Base.trigger = function(event, data) {
    data.type = event;
    return pi.event.trigger("" + this.resources_name + "_update", data, false);
  };

  Base.off = function(callback) {
    if (callback != null) {
      return pi.event.off("" + this.resources_name + "_update", callback);
    } else {
      return pi.event.off("" + this.resources_name + "_update");
    }
  };

  Base.all = function() {
    return this.__all__.slice();
  };

  Base.where = function(params) {
    var el, _i, _len, _ref, _results;
    _ref = this.__all__;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      el = _ref[_i];
      if (utils.matchers.object_ext(params)(el)) {
        _results.push(el);
      }
    }
    return _results;
  };

  Base.view = function(params) {
    var view;
    view = new pi.resources.Association(this, params, {
      scope: params,
      copy: false,
      source: this
    });
    view.reload();
    return view;
  };

  Base._wrap = function(el) {
    if (el instanceof pi.resources.Base) {
      return utils.obj.wrap(el.constructor.resource_name, el);
    } else {
      return el;
    }
  };

  function Base(data) {
    if (data == null) {
      data = {};
    }
    Base.__super__.constructor.apply(this, arguments);
    this._changes = {};
    if ((data.id != null) && !data.__temp__) {
      this._persisted = true;
    }
    this.initialize(data);
  }

  Base.prototype.initialize = function(data) {
    if (this._initialized) {
      return;
    }
    this.set(data, true);
    return this._initialized = true;
  };

  Base.register_callback('initialize');

  Base.prototype.created = function(temp_id) {
    this;
    return this.constructor.created(this, temp_id);
  };

  Base.prototype.dispose = function() {
    var key, _;
    if (this.disposed) {
      return;
    }
    for (key in this) {
      if (!__hasProp.call(this, key)) continue;
      _ = this[key];
      delete this[key];
    }
    this.disposed = true;
    return this;
  };

  Base.register_callback('dispose', {
    as: 'destroy'
  });

  Base.prototype.remove = function(silent) {
    if (silent == null) {
      silent = false;
    }
    return this.constructor.remove(this, silent);
  };

  Base.prototype.attributes = function() {
    var change, key, res, _ref;
    res = {};
    _ref = this._changes;
    for (key in _ref) {
      change = _ref[key];
      res[key] = change.val;
    }
    return res;
  };

  Base.prototype.association = function(name) {
    var _ref;
    return ((_ref = this.__associations__) != null ? _ref.indexOf(name) : void 0) > -1;
  };

  Base.prototype.set = function(params, silent) {
    var key, type, val, _changed, _old_id, _was_id;
    _changed = false;
    _was_id = !!this.id && !(this.__temp__ === true);
    _old_id = this.id;
    for (key in params) {
      if (!__hasProp.call(params, key)) continue;
      val = params[key];
      if (this[key] !== val && !(typeof this[key] === 'function') && !((this.__associations__ != null) && (__indexOf.call(this.__associations__, key) >= 0))) {
        _changed = true;
        this._changes[key] = {
          old_val: this[key],
          val: val
        };
        this[key] = val;
      }
    }
    if ((this.id | 0) && !_was_id) {
      delete this.__temp__;
      this._persisted = true;
      this.__tid__ = _old_id;
      type = pi.ResourceEvent.Create;
      this.created(_old_id);
    } else {
      type = pi.ResourceEvent.Update;
    }
    if (_changed && !silent) {
      this.trigger(type, (type === pi.ResourceEvent.Create ? this : this._changes));
    }
    return this;
  };

  Base.register_callback('set', {
    as: 'update'
  });

  Base.prototype.trigger = function(e, data, bubbles) {
    if (bubbles == null) {
      bubbles = false;
    }
    Base.__super__.trigger.apply(this, arguments);
    return this.constructor.trigger(e, this.constructor._wrap(this));
  };

  Base.prototype.trigger_assoc_event = function(name, type, data) {
    if (typeof this["on_" + name + "_update"] === 'function') {
      this["on_" + name + "_update"].call(this, type, data);
    }
    return this.trigger(pi.ResourceEvent.Update, utils.obj.wrap(name, true));
  };

  return Base;

})(pi.EventDispatcher);

pi.resources.create = function(name, parent) {
  var klass;
  if (parent == null) {
    parent = $r.Base;
  }
  klass = utils.subclass(parent);
  if (name != null) {
    if (typeof name === 'string') {
      klass.set_resource(name);
      pi.resources[utils.capitalize(utils.camelCase(name))] = klass;
    } else if (Array.isArray(name)) {
      klass.set_resource(name[0], name[1]);
      pi.resources[utils.capitalize(utils.camelCase(name[0]))] = klass;
    }
  } else {
    klass.set_resource("unknown");
  }
  return klass;
};



},{"../core":34,"./events":69}],69:[function(require,module,exports){
'use strict';
var pi;

pi = require('../core');

pi.ResourceEvent = {
  Update: 'update',
  Create: 'create',
  Destroy: 'destroy',
  Load: 'load'
};



},{"../core":34}],70:[function(require,module,exports){
'use strict';
require('./base');

require('./view');

require('./association');

require('./rest');

require('./modules');



},{"./association":67,"./base":68,"./modules":73,"./rest":75,"./view":76}],71:[function(require,module,exports){
'use strict';
var pi, utils, _false, _true;

pi = require('../../core');

require('../rest');

utils = pi.utils;

_true = function() {
  return true;
};

_false = function() {
  return false;
};

pi.resources.HasMany = (function() {
  function HasMany() {}

  HasMany.extended = function(klass) {
    return true;
  };

  HasMany.has_many = function(name, params) {
    var _old, _update_filter;
    if (params == null) {
      throw Error("Has many require at least 'source' param");
    }
    utils.extend(params, {
      path: ":resources/:id/" + name,
      method: 'get'
    });
    this.register_association(name);
    if (typeof params.update_if === 'function') {
      _update_filter = params.update_if;
    } else if (params.update_if === true) {
      _update_filter = _true;
    }
    this.prototype[name] = function() {
      var default_scope, options;
      if (this["__" + name + "__"] == null) {
        options = {
          name: name,
          owner: this
        };
        if (params.belongs_to === true) {
          options.key = params.key || ("" + this.constructor.resource_name + "_id");
          if (params.copy == null) {
            options.copy = false;
          }
          options._scope = params.scope;
          default_scope = utils.obj.wrap(options.key, this.id);
          if (params.scope == null) {
            options.scope = this._persisted ? default_scope : false;
          } else {
            options.scope = params.scope;
          }
          if (params.params != null) {
            params.params.push("" + this.constructor.resource_name + "_id");
          }
        }
        utils.extend(options, params);
        this["__" + name + "__"] = new pi.resources.Association(params.source, options.scope, options);
        if (options.scope !== false) {
          this["__" + name + "__"].load(params.source.where(options.scope));
        }
        if (params.update_if) {
          this["__" + name + "__"].listen((function(_this) {
            return function(e) {
              var data;
              data = e.data[params.source.resources_name] || e.data[params.source.resource_name];
              if (_update_filter(e.data.type, data)) {
                return _this.trigger_assoc_event(name, e.data.type, data);
              }
            };
          })(this));
        }
      }
      return this["__" + name + "__"];
    };
    if (params.route === true) {
      this.routes({
        member: [
          {
            action: "load_" + name,
            path: params.path,
            method: params.method
          }
        ]
      });
      this.prototype["on_load_" + name] = function(data) {
        this["" + name + "_loaded"] = true;
        if (data[name] != null) {
          return this[name]().load(data[name]);
        }
      };
    }
    this.after_update(function(data) {
      if (data instanceof pi.resources.Base) {
        return;
      }
      if (data[name]) {
        this["" + name + "_loaded"] = true;
        return this[name]().load(data[name]);
      }
    });
    this.after_initialize(function() {
      return this[name]();
    });
    if (params.destroy === true) {
      this.before_destroy(function() {
        return this[name]().clear_all(true);
      });
    }
    if (params.attribute === true) {
      _old = this.prototype.attributes;
      return this.prototype.attributes = function() {
        var data;
        data = _old.call(this);
        data[name] = this[name]().serialize();
        return data;
      };
    }
  };

  return HasMany;

})();



},{"../../core":34,"../rest":75}],72:[function(require,module,exports){
'use strict';
var pi, utils, _false, _true;

pi = require('../../core');

require('../rest');

utils = pi.utils;

_true = function() {
  return true;
};

_false = function() {
  return false;
};

pi.resources.HasOne = (function() {
  function HasOne() {}

  HasOne.extended = function(klass) {
    return true;
  };

  HasOne.has_one = function(name, params) {
    var bind_fun, resource_name, _old, _update_filter;
    if (params == null) {
      throw Error("Has one require at least 'source' param");
    }
    params.foreign_key || (params.foreign_key = "" + this.resource_name + "_id");
    resource_name = params.source.resource_name;
    bind_fun = "bind_" + name;
    this.register_association(name);
    if (typeof params.update_if === 'function') {
      _update_filter = params.update_if;
    } else if (params.update_if === true) {
      _update_filter = _true;
    } else {
      _update_filter = _false;
    }
    params.source.listen((function(_this) {
      return function(e) {
        var el, target, _i, _len, _ref, _results;
        if (!_this.all().length) {
          return;
        }
        e = e.data;
        if (e.type === pi.ResourceEvent.Load) {
          _ref = params.source.all();
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            el = _ref[_i];
            if (el[params.foreign_key] && (target = _this.get(el[params.foreign_key])) && target.association(name)) {
              _results.push(target[bind_fun](el));
            } else {
              _results.push(void 0);
            }
          }
          return _results;
        } else {
          el = e[resource_name];
          if (el[params.foreign_key] && (target = _this.get(el[params.foreign_key])) && target.association(name)) {
            if (e.type === pi.ResourceEvent.Destroy) {
              delete _this[name];
            } else if (e.type === pi.ResourceEvent.Create) {
              target[bind_fun](el, true);
            }
            if (_update_filter(e, el)) {
              return target.trigger_assoc_event(name, e.type, utils.obj.wrap(name, _this[name]));
            }
          }
        }
      };
    })(this));
    this.prototype[bind_fun] = function(el, silent) {
      if (silent == null) {
        silent = false;
      }
      if (el == null) {
        return;
      }
      this[name] = el;
      if (this._persisted && !this[name][params.foreign_key]) {
        this[name][params.foreign_key] = this.id;
      }
      if (!(silent || !_update_filter(null, el))) {
        return this.trigger_assoc_event(name, pi.ResourceEvent.Create, utils.obj.wrap(name, this[name]));
      }
    };
    this.after_initialize(function() {
      var el;
      if (this._persisted && (el = params.source.get_by(utils.obj.wrap(params.foreign_key, this.id)))) {
        return this[bind_fun](el, true);
      }
    });
    this.after_update(function(data) {
      var el;
      if (data instanceof pi.resources.Base) {
        return;
      }
      if (this._persisted && !this[name] && (el = params.source.get_by(utils.obj.wrap(params.foreign_key, this.id)))) {
        this[bind_fun](el, true);
      }
      if (data[name]) {
        if (this[name] instanceof pi.resources.Base) {
          return this[name].set(data[name]);
        } else {
          return this[bind_fun](params.source.build(data[name]));
        }
      }
    });
    if (params.destroy === true) {
      this.before_destroy(function() {
        var _ref;
        return (_ref = this[name]) != null ? _ref.remove() : void 0;
      });
    }
    if (params.attribute === true) {
      _old = this.prototype.attributes;
      return this.prototype.attributes = function() {
        var data;
        data = _old.call(this);
        data[name] = this[name].attributes();
        return data;
      };
    }
  };

  return HasOne;

})();



},{"../../core":34,"../rest":75}],73:[function(require,module,exports){
'use strict';
require('./query');

require('./has_many');

require('./has_one');



},{"./has_many":71,"./has_one":72,"./query":74}],74:[function(require,module,exports){
'use strict';
var pi, utils;

pi = require('../../core');

require('../rest');

utils = pi.utils;

pi.resources.Query = (function() {
  function Query() {}

  Query.extended = function(klass) {
    return klass.query_path = klass.fetch_path;
  };

  Query.query = function(params) {
    return this._request(this.query_path, 'get', params).then((function(_this) {
      return function(response) {
        return _this.on_all(response);
      };
    })(this));
  };

  return Query;

})();



},{"../../core":34,"../rest":75}],75:[function(require,module,exports){
'use strict';
var pi, utils, _double_slashes_reg, _path_reg, _tailing_slash_reg,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __slice = [].slice;

pi = require('../core');

require('./base');

utils = pi.utils;

_path_reg = /:(\w+)\b/g;

_double_slashes_reg = /\/\//;

_tailing_slash_reg = /\/$/;

pi.resources.REST = (function(_super) {
  __extends(REST, _super);

  REST._rscope = "/:path";

  REST.prototype.wrap_attributes = false;

  REST.can_create = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return this.__deps__ = (this.__deps__ || (this.__deps__ = [])).concat(args);
  };

  REST.prototype.__filter_params__ = false;

  REST.params = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    if (!this.prototype.hasOwnProperty("__filter_params__")) {
      this.prototype.__filter_params__ = [];
      this.prototype.__filter_params__.push('id');
    }
    return this.prototype.__filter_params__ = this.prototype.__filter_params__.concat(args);
  };

  REST.set_resource = function(plural, singular) {
    REST.__super__.constructor.set_resource.apply(this, arguments);
    this.routes({
      collection: [
        {
          action: 'show',
          path: ":resources/:id",
          method: "get"
        }, {
          action: 'fetch',
          path: ":resources",
          method: "get"
        }
      ],
      member: [
        {
          action: 'update',
          path: ":resources/:id",
          method: "patch"
        }, {
          action: '__destroy',
          path: ":resources/:id",
          method: "delete"
        }, {
          action: 'create',
          path: ":resources",
          method: "post"
        }
      ]
    });
    return this.prototype["destroy_path"] = ":resources/:id";
  };

  REST.routes = function(data) {
    var spec, _fn, _i, _j, _len, _len1, _ref, _ref1, _results;
    if (data.collection != null) {
      _ref = data.collection;
      _fn = (function(_this) {
        return function(spec) {
          _this[spec.action] = function(params) {
            if (params == null) {
              params = {};
            }
            return this._request(spec.path, spec.method, params).then((function(_this) {
              return function(response) {
                var dep, _j, _len1, _ref1;
                if (_this.__deps__ != null) {
                  _ref1 = _this.__deps__;
                  for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
                    dep = _ref1[_j];
                    dep.from_data(response);
                  }
                }
                if (_this["on_" + spec.action] != null) {
                  return _this["on_" + spec.action](response);
                } else {
                  return _this.on_all(response);
                }
              };
            })(this));
          };
          return _this["" + spec.action + "_path"] = spec.path;
        };
      })(this);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        spec = _ref[_i];
        _fn(spec);
      }
    }
    if (data.member != null) {
      _ref1 = data.member;
      _results = [];
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        spec = _ref1[_j];
        _results.push((function(_this) {
          return function(spec) {
            _this.prototype[spec.action] = function(params) {
              if (params == null) {
                params = {};
              }
              return this.constructor._request(spec.path, spec.method, utils.merge(params, {
                id: this.id
              }), this).then((function(_this) {
                return function(response) {
                  var dep, _k, _len2, _ref2;
                  if (_this.constructor.__deps__ != null) {
                    _ref2 = _this.constructor.__deps__;
                    for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
                      dep = _ref2[_k];
                      dep.from_data(response);
                    }
                  }
                  if (_this["on_" + spec.action] != null) {
                    return _this["on_" + spec.action](response);
                  } else {
                    return _this.on_all(response);
                  }
                };
              })(this));
            };
            return _this.prototype["" + spec.action + "_path"] = spec.path;
          };
        })(this)(spec));
      }
      return _results;
    }
  };

  REST.routes_scope = function(scope) {
    return this._rscope = scope;
  };

  REST._interpolate_path = function(path, params, target) {
    var flag, part, path_parts, val, vars, _i, _len;
    path = this._rscope.replace(":path", path).replace(_double_slashes_reg, "/").replace(_tailing_slash_reg, '');
    path_parts = path.split(_path_reg);
    if (this.prototype.wrap_attributes && (params[this.resource_name] != null) && (typeof params[this.resource_name] === 'object')) {
      vars = utils.extend(params[this.resource_name], params, false, [this.resource_name]);
    } else {
      vars = params;
    }
    path = "";
    flag = false;
    for (_i = 0, _len = path_parts.length; _i < _len; _i++) {
      part = path_parts[_i];
      if (flag) {
        val = vars[part] != null ? vars[part] : target != null ? target[part] : void 0;
        if (val == null) {
          throw Error("undefined param: " + part);
        }
        path += val;
      } else {
        path += part;
      }
      flag = !flag;
    }
    return path;
  };

  REST.error = function(action, message) {
    return pi.event.trigger("net_error", {
      resource: this.resources_name,
      action: action,
      message: message
    });
  };

  REST._request = function(path, method, params, target) {
    path = this._interpolate_path(path, utils.merge(params, {
      resources: this.resources_name,
      resource: this.resource_name
    }), target);
    return pi.net[method].call(null, path, params)["catch"]((function(_this) {
      return function(error) {
        _this.error(error.message);
        throw error;
      };
    })(this));
  };

  REST.on_all = function(data) {
    if (data[this.resources_name] != null) {
      data[this.resources_name] = this.load(data[this.resources_name]);
    }
    return data;
  };

  REST.on_show = function(data) {
    var el;
    if (data[this.resource_name] != null) {
      el = this.build(data[this.resource_name]);
      el.commit();
      return el;
    }
  };

  REST.build = function() {
    var el;
    el = REST.__super__.constructor.build.apply(this, arguments);
    return el;
  };

  REST.find = function(id) {
    var el;
    el = this.get(id);
    if (el != null) {
      return utils.promise.resolved_promise(el);
    } else {
      return this.show({
        id: id
      });
    }
  };

  REST.find_by = function(params) {
    var el;
    el = this.get_by(params);
    if (el != null) {
      return utils.promise.resolved_promise(el);
    } else {
      return this.show(params);
    }
  };

  REST.create = function(data) {
    var el;
    el = this.build(data);
    return el.save();
  };

  function REST(data) {
    REST.__super__.constructor.apply(this, arguments);
    this._snapshot = data;
  }

  REST.prototype.destroy = function() {
    if (this._persisted) {
      return this.__destroy();
    } else {
      return utils.promise.as_promise((function(_this) {
        return function() {
          return _this.remove();
        };
      })(this));
    }
  };

  REST.prototype.on_destroy = function(data) {
    this.constructor.remove(this);
    return data;
  };

  REST.alias('on___destroy', 'on_destroy');

  REST.prototype.on_all = function(data) {
    var params;
    params = data[this.constructor.resource_name];
    if ((params != null) && params.id === this.id) {
      this.set(params);
      this.commit();
      return this;
    }
  };

  REST.prototype.on_create = function(data) {
    var params;
    params = data[this.constructor.resource_name];
    if (params != null) {
      this.set(params, true);
      this.commit();
      this.trigger(pi.ResourceEvent.Create);
      return this;
    }
  };

  REST.prototype.attributes = function() {
    if (this.__attributes__changed__) {
      if (this.__filter_params__) {
        this.__attributes__ = utils.extract(this, this.__filter_params__);
      } else {
        this.__attributes__ = REST.__super__.attributes.apply(this, arguments);
      }
    }
    return this.__attributes__;
  };

  REST.prototype.set = function() {
    this.__attributes__changed__ = true;
    return REST.__super__.set.apply(this, arguments);
  };

  REST.prototype.save = function(params) {
    var attrs;
    if (params == null) {
      params = {};
    }
    attrs = this.attributes();
    utils.extend(attrs, params, true);
    attrs = this.wrap_attributes ? this._wrap(attrs) : attrs;
    if (this._persisted) {
      return this.update(attrs);
    } else {
      return this.create(attrs);
    }
  };

  REST.prototype.commit = function() {
    var key, param, _i, _len, _ref;
    _ref = this._changes;
    for (param = _i = 0, _len = _ref.length; _i < _len; param = ++_i) {
      key = _ref[param];
      this._snapshot[key] = param.val;
    }
    this._changes = {};
    return this._snapshot;
  };

  REST.prototype.rollback = function() {
    var key, param, _i, _len, _ref;
    _ref = this._changes;
    for (param = _i = 0, _len = _ref.length; _i < _len; param = ++_i) {
      key = _ref[param];
      this[key] = this._snapshot[key];
    }
  };

  REST.register_callback('save');

  REST.prototype._wrap = function(attributes) {
    var data;
    data = {};
    data[this.constructor.resource_name] = attributes;
    return data;
  };

  return REST;

})(pi.resources.Base);



},{"../core":34,"./base":68}],76:[function(require,module,exports){
'use strict';
var pi, utils,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

pi = require('../core');

require('./base');

utils = pi.utils;

pi.resources.ViewItem = (function(_super) {
  __extends(ViewItem, _super);

  function ViewItem(view, data, options) {
    this.view = view;
    this.options = options != null ? options : {};
    ViewItem.__super__.constructor.apply(this, arguments);
    if ((this.options.params != null) && this.options.params.indexOf('id') < 0) {
      this.options.params.push('id');
    }
    this._changes = {};
    this.set(data, true);
  }

  utils.extend(ViewItem.prototype, pi.resources.Base.prototype, false);

  ViewItem.prototype.created = function(tid) {
    return this.view.created(this, tid);
  };

  ViewItem.prototype.trigger = function(e, data, bubbles) {
    if (bubbles == null) {
      bubbles = true;
    }
    ViewItem.__super__.trigger.apply(this, arguments);
    return this.view.trigger(e, this.view._wrap(this));
  };

  ViewItem.prototype.attributes = function() {
    var data;
    if (this.options.params != null) {
      data = utils.extract(this, this.options.params);
      if (this.options.id_alias != null) {
        if (this.options.id_alias) {
          data[this.options.id_alias] = data.id;
        }
        delete data.id;
      }
      return data;
    } else {
      return pi.resources.Base.prototype.attributes.call(this);
    }
  };

  return ViewItem;

})(pi.EventDispatcher);

pi.resources.View = (function(_super) {
  __extends(View, _super);

  function View(resources, scope, options) {
    this.resources = resources;
    this.options = options != null ? options : {};
    View.__super__.constructor.apply(this, arguments);
    this.__all_by_id__ = {};
    this.__all_by_tid__ = {};
    this.__all__ = [];
    this.resources_name = this.resources.resources_name;
    this.resource_name = this.resources.resource_name;
    this._filter = (scope != null) && scope !== false ? utils.matchers.object_ext(scope) : function() {
      return true;
    };
    this.resources.listen((function(_this) {
      return function(e) {
        var el, _name;
        el = e.data[_this.resource_name];
        if (el != null) {
          if (!_this._filter(el)) {
            return;
          }
        }
        return typeof _this[_name = "on_" + e.data.type] === "function" ? _this[_name](el) : void 0;
      };
    })(this));
  }

  utils.extend(View.prototype, pi.resources.Base);

  View.prototype.on_update = function(el) {
    var view_item;
    if ((view_item = this.get(el.id))) {
      return view_item.set(el.attributes());
    }
  };

  View.prototype.on_destroy = function(el) {
    var view_item;
    if ((view_item = this.get(el.id))) {
      return this.remove(view_item);
    }
  };

  View.prototype.clear_all = function(force) {
    var el, _i, _j, _len, _len1, _ref, _ref1;
    if (force == null) {
      force = false;
    }
    if (!((this.options.copy === false) && (force === false))) {
      if (force && !this.options.copy) {
        this.__all_by_id__ = {};
        this.__all_by_tid__ = {};
        _ref = this.__all__;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          el = _ref[_i];
          el.remove();
        }
      } else {
        _ref1 = this.__all__;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          el = _ref1[_j];
          el.dispose();
        }
      }
    }
    this.__all_by_id__ = {};
    this.__all_by_tid__ = {};
    return this.__all__.length = 0;
  };

  View.prototype.build = function(data, silent, params) {
    var el;
    if (data == null) {
      data = {};
    }
    if (silent == null) {
      silent = false;
    }
    if (params == null) {
      params = {};
    }
    if (!(el = this.get(data.id))) {
      if (data instanceof pi.resources.Base && this.options.copy === false) {
        el = data;
      } else {
        if (data instanceof pi.resources.Base) {
          data = data.attributes();
        }
        utils.extend(data, params, true);
        el = new pi.resources.ViewItem(this, data, this.options);
      }
      if (el.id) {
        this.add(el);
        if (!silent) {
          this.trigger(pi.ResourceEvent.Create, this._wrap(el));
        }
      }
      return el;
    } else {
      return el.set(data, silent);
    }
  };

  View.prototype._wrap = function(el) {
    if (el instanceof pi.resources.ViewItem) {
      return utils.obj.wrap(el.view.resource_name, el);
    } else if (el instanceof pi.resources.Base) {
      return utils.obj.wrap(el.constructor.resource_name, el);
    } else {
      return el;
    }
  };

  View.prototype.serialize = function() {
    var el, res, _i, _len, _ref;
    res = [];
    _ref = this.all();
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      el = _ref[_i];
      res.push(el.attributes());
    }
    return res;
  };

  View.prototype.listen = function(callback) {
    return this.on("update", callback);
  };

  View.prototype.trigger = function(event, data) {
    data.type = event;
    return View.__super__.trigger.call(this, "update", data);
  };

  View.prototype.off = function(callback) {
    return View.__super__.off.call(this, "update", callback);
  };

  return View;

})(pi.EventDispatcher);



},{"../core":34,"./base":68}],77:[function(require,module,exports){
'use strict';
var pi, utils,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

pi = require('../core');

require('../components/base');

utils = pi.utils;

utils.extend(pi.Base.prototype, {
  view: function() {
    return this.__view__ || (this.__view__ = this._find_view());
  },
  _find_view: function() {
    var comp;
    comp = this;
    while (comp) {
      if (comp.is_view === true) {
        return comp;
      }
      comp = comp.host;
    }
  }
});

pi.BaseView = (function(_super) {
  __extends(BaseView, _super);

  function BaseView() {
    return BaseView.__super__.constructor.apply(this, arguments);
  }

  BaseView.prototype.is_view = true;

  BaseView.prototype.postinitialize = function() {
    var controller_klass;
    controller_klass = null;
    if (this.options.controller) {
      controller_klass = utils.obj.get_class_path(pi.controllers, this.options.controller);
    }
    controller_klass || (controller_klass = this.default_controller);
    if (controller_klass != null) {
      this.controller = new controller_klass(this);
      return pi.app.page.add_context(this.controller, this.options.main);
    } else {
      return utils.warning("controller not found", controller_klass);
    }
  };

  BaseView.prototype.loaded = function(data) {};

  BaseView.prototype.reloaded = function(data) {};

  BaseView.prototype.switched = function() {};

  BaseView.prototype.unloaded = function() {};

  return BaseView;

})(pi.Base);



},{"../components/base":5,"../core":34}],78:[function(require,module,exports){
'use strict';
require('./base');



},{"./base":77}],79:[function(require,module,exports){

},{}],80:[function(require,module,exports){
(function (process){
// Copyright Joyent, Inc. and other Node contributors.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to permit
// persons to whom the Software is furnished to do so, subject to the
// following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
// NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
// USE OR OTHER DEALINGS IN THE SOFTWARE.

// resolves . and .. elements in a path array with directory names there
// must be no slashes, empty elements, or device names (c:\) in the array
// (so also no leading and trailing slashes - it does not distinguish
// relative and absolute paths)
function normalizeArray(parts, allowAboveRoot) {
  // if the path tries to go above the root, `up` ends up > 0
  var up = 0;
  for (var i = parts.length - 1; i >= 0; i--) {
    var last = parts[i];
    if (last === '.') {
      parts.splice(i, 1);
    } else if (last === '..') {
      parts.splice(i, 1);
      up++;
    } else if (up) {
      parts.splice(i, 1);
      up--;
    }
  }

  // if the path is allowed to go above the root, restore leading ..s
  if (allowAboveRoot) {
    for (; up--; up) {
      parts.unshift('..');
    }
  }

  return parts;
}

// Split a filename into [root, dir, basename, ext], unix version
// 'root' is just a slash, or nothing.
var splitPathRe =
    /^(\/?|)([\s\S]*?)((?:\.{1,2}|[^\/]+?|)(\.[^.\/]*|))(?:[\/]*)$/;
var splitPath = function(filename) {
  return splitPathRe.exec(filename).slice(1);
};

// path.resolve([from ...], to)
// posix version
exports.resolve = function() {
  var resolvedPath = '',
      resolvedAbsolute = false;

  for (var i = arguments.length - 1; i >= -1 && !resolvedAbsolute; i--) {
    var path = (i >= 0) ? arguments[i] : process.cwd();

    // Skip empty and invalid entries
    if (typeof path !== 'string') {
      throw new TypeError('Arguments to path.resolve must be strings');
    } else if (!path) {
      continue;
    }

    resolvedPath = path + '/' + resolvedPath;
    resolvedAbsolute = path.charAt(0) === '/';
  }

  // At this point the path should be resolved to a full absolute path, but
  // handle relative paths to be safe (might happen when process.cwd() fails)

  // Normalize the path
  resolvedPath = normalizeArray(filter(resolvedPath.split('/'), function(p) {
    return !!p;
  }), !resolvedAbsolute).join('/');

  return ((resolvedAbsolute ? '/' : '') + resolvedPath) || '.';
};

// path.normalize(path)
// posix version
exports.normalize = function(path) {
  var isAbsolute = exports.isAbsolute(path),
      trailingSlash = substr(path, -1) === '/';

  // Normalize the path
  path = normalizeArray(filter(path.split('/'), function(p) {
    return !!p;
  }), !isAbsolute).join('/');

  if (!path && !isAbsolute) {
    path = '.';
  }
  if (path && trailingSlash) {
    path += '/';
  }

  return (isAbsolute ? '/' : '') + path;
};

// posix version
exports.isAbsolute = function(path) {
  return path.charAt(0) === '/';
};

// posix version
exports.join = function() {
  var paths = Array.prototype.slice.call(arguments, 0);
  return exports.normalize(filter(paths, function(p, index) {
    if (typeof p !== 'string') {
      throw new TypeError('Arguments to path.join must be strings');
    }
    return p;
  }).join('/'));
};


// path.relative(from, to)
// posix version
exports.relative = function(from, to) {
  from = exports.resolve(from).substr(1);
  to = exports.resolve(to).substr(1);

  function trim(arr) {
    var start = 0;
    for (; start < arr.length; start++) {
      if (arr[start] !== '') break;
    }

    var end = arr.length - 1;
    for (; end >= 0; end--) {
      if (arr[end] !== '') break;
    }

    if (start > end) return [];
    return arr.slice(start, end - start + 1);
  }

  var fromParts = trim(from.split('/'));
  var toParts = trim(to.split('/'));

  var length = Math.min(fromParts.length, toParts.length);
  var samePartsLength = length;
  for (var i = 0; i < length; i++) {
    if (fromParts[i] !== toParts[i]) {
      samePartsLength = i;
      break;
    }
  }

  var outputParts = [];
  for (var i = samePartsLength; i < fromParts.length; i++) {
    outputParts.push('..');
  }

  outputParts = outputParts.concat(toParts.slice(samePartsLength));

  return outputParts.join('/');
};

exports.sep = '/';
exports.delimiter = ':';

exports.dirname = function(path) {
  var result = splitPath(path),
      root = result[0],
      dir = result[1];

  if (!root && !dir) {
    // No dirname whatsoever
    return '.';
  }

  if (dir) {
    // It has a dirname, strip trailing slash
    dir = dir.substr(0, dir.length - 1);
  }

  return root + dir;
};


exports.basename = function(path, ext) {
  var f = splitPath(path)[2];
  // TODO: make this comparison case-insensitive on windows?
  if (ext && f.substr(-1 * ext.length) === ext) {
    f = f.substr(0, f.length - ext.length);
  }
  return f;
};


exports.extname = function(path) {
  return splitPath(path)[3];
};

function filter (xs, f) {
    if (xs.filter) return xs.filter(f);
    var res = [];
    for (var i = 0; i < xs.length; i++) {
        if (f(xs[i], i, xs)) res.push(xs[i]);
    }
    return res;
}

// String.prototype.substr - negative index don't work in IE8
var substr = 'ab'.substr(-1) === 'b'
    ? function (str, start, len) { return str.substr(start, len) }
    : function (str, start, len) {
        if (start < 0) start = str.length + start;
        return str.substr(start, len);
    }
;

}).call(this,require('_process'))
},{"_process":81}],81:[function(require,module,exports){
// shim for using process in browser

var process = module.exports = {};

process.nextTick = (function () {
    var canSetImmediate = typeof window !== 'undefined'
    && window.setImmediate;
    var canPost = typeof window !== 'undefined'
    && window.postMessage && window.addEventListener
    ;

    if (canSetImmediate) {
        return function (f) { return window.setImmediate(f) };
    }

    if (canPost) {
        var queue = [];
        window.addEventListener('message', function (ev) {
            var source = ev.source;
            if ((source === window || source === null) && ev.data === 'process-tick') {
                ev.stopPropagation();
                if (queue.length > 0) {
                    var fn = queue.shift();
                    fn();
                }
            }
        }, true);

        return function nextTick(fn) {
            queue.push(fn);
            window.postMessage('process-tick', '*');
        };
    }

    return function nextTick(fn) {
        setTimeout(fn, 0);
    };
})();

process.title = 'browser';
process.browser = true;
process.env = {};
process.argv = [];

function noop() {}

process.on = noop;
process.addListener = noop;
process.once = noop;
process.off = noop;
process.removeListener = noop;
process.removeAllListeners = noop;
process.emit = noop;

process.binding = function (name) {
    throw new Error('process.binding is not supported');
}

// TODO(shtylman)
process.cwd = function () { return '/' };
process.chdir = function (dir) {
    throw new Error('process.chdir is not supported');
};

},{}]},{},[52]);
