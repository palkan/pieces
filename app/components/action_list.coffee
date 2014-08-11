do (context = this) ->
  "use strict"
  # shortcuts
  pi = context.pi  = context.pi || {}
  utils = pi.utils

  # Action list component (list + selectable, sortable, searchable, ...)

  class pi.ActionList extends pi.List
    @include_plugins pi.List.Selectable, pi.List.Searchable, pi.List.Sortable, pi.List.Filterable, pi.List.ScrollEnd

  pi.Guesser.rules_for 'action_list', ['pi-action-list']  