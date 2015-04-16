## 0.4.0
* Bindings
* Scoped component
* BaseInput is listening for 'input' event to update 'val'
* Move components to their own namespace (`pi.components`).
* Extract List to separate library.
* Add Simple Templates.
* Add global vars to REST. Add `REST.path` and `REST#path` methods.
* `routes_scope` -> `routes_namespace`
* Refactor controllers. Add Context and strategies. Create controllers on the fly from DOM data.
* Utils separated into subclasses.
* Separate core lib from custom components and styles.
* Now we have a grammar to parse and compile HTML-inlined functions. And it works)