'use strict'
pi = require 'core'
require './base/list'
require 'plugins/list'
utils = pi.utils

# Action list component (list + selectable, sortable, searchable, ...)

class pi.ActionList extends pi.List
  @include_plugins pi.List.Selectable, pi.List.Searchable, pi.List.Sortable, pi.List.Filterable, pi.List.ScrollEnd

pi.Guesser.rules_for 'action_list', ['pi-action-list']  