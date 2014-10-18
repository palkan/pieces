'use strict'
pi = require '../../core'
require '../../components/base/list'
require '../../plugins/list'
utils = pi.utils

# Action list component (list + selectable, sortable, searchable, ...)

class pi.ActionList extends pi.List
  @include_plugins pi.List.Selectable, pi.List.Sortable, pi.List.Searchable, pi.List.Filterable, pi.List.ScrollEnd