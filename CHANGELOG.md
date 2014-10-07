## 0.3.5
* add HasOne module to resources
* add 'from_data' and 'can_create' to resources
* add Promise helpers to utils
* add ListController query 'pipeline' 
* enhance BaseInput with 'serialize' and 'deafault-value' options
* enhance Checkbox with 'true-value' and 'false-value' options
* add 'accept' to FileInput and 'rxp' option to filter file names
* upd Compiler

## 0.3.4
* add RadioGroup component
* add Stepper component
* refactor 'select_item' and 'deselect_item'
* upd Checkbox styles 
* add Event.captured property and fix event capturing in List's plugin
* remove List item 'list-index' data prop, add List item record.\__list\_index\__
* add 'temp_id' functionality to Resource
* add Plugin.dispose functionality
* add 'resize' event (works with window resize and with 'width','height','size' methods)

## 0.3.3
* add Form.validate method (now run before submit always)
* add Scrollable
* fix events aliases bug
* fix Association bug (resource update for not 'belongs_to' association)
* Form now read all values before submit
* add ability to bind scroll_object by selector to ScrollEnd

## 0.3.2
* seperate Compiler from Pieces Base
* support multiple args in pi_call
* add nested_select global select types
* add modifiers to Compiler
* fix empty string serialize
* support wrapped resource params within interpolation
* add NodWin

## 0.3.1
* add 'key' param to association
* by default 'belongs_to' associations set 'copy' to false
* add 'destroy' param to association
* many associations fixes

## 0.3.0
* add associations to resources
* add 'load' type event to resources and restful list

## 0.2.5
* fix bug with double-piecification on list item update
* fix nested_select events; add deeply-nested lists support
* add resources View
* add 'default-value' to SelectField 
* make REST.save to accept 'params' (which overwrite attributes)
* REST routes support instance properties 

## 0.2.4
* fix Form set value 
* add 'wrap_parameters' property to REST resource
* upd 'register_callback'
* improve list plugins update handlers
* update page context switching flow 
* fix debounce
* upd net error handling
* add 'params' method to REST to describe attributes for create/update
* add 'save' callbacks for REST
* add 'remove_items' to list
* upd path iterpolation (now scope can contain params)

## 0.2.3
* add 'controller' property to View
* PopupContainer prevent close if close function return 'false' 
* Separate ListView into modules: Loadable, Listable
* unify inputs events (all send update event with value) and store them as constants
* add placeholder as required component for SelectInput
* fix setting value for Checkbox and SelectInput 
* move FormerJS to Pieces as pi.Former
* add Form component
* add Form validations

## 0.2.2
* add 'renderable' plugin for any component
* add 'restful' plugin for any _renderable_ component
* fix component 'remove' (remove sub-components too)
* add 'remove_children' to Nod (remove and dispose if child is Nod)
* add 'records()' method to List


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