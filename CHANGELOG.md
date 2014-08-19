## 0.2.2
* add 'renderable' plugin for any component
* add 'restful' plugin for any _renderable_ component
* fix component 'remove' (remove sub-components too)
* add 'remove_children' to Nod (remove and dispose if child is Nod)

## 0.2.1 
* add Paginated module to Controllers
* resource query response 'bubble' from resource as is (but only resources data is converted to resources)
* add 'merge_classes' property to List which indicates what classes should not be removed on item update
*  rename View.<Some> to <Some>View
*  add popup  

## 0.2.0 (2014-08)
* no more jQuery
* add pi.app as main object containing top level component (pi.app.view)
* data-pi -> data-pid || pid
* scoped pids (some_component_child_child -> some.component.child.child)
* list items are all pi.Base components by default (not Objects {...,nod: Nod})
* drag_select -> move_select and it works as expected (clear_selection() then select())
* component guesser! (no need of data-component, write custom rules)
* some css
* commonjs
* RVC - resources, view, controller
* more components (SearchInput, SelectInput, FileInput...)

## 0.0.1 (2014-01-31)
* First very-very-alpha (core + utils)