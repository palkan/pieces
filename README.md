# JS Pieces
Simple framework to make your pages interactive (written mostly in CoffeScript)

## Deps
JQuery, moment.js

## Dev Deps
NodeJS+Bower+Brunch

## Features 
* Interactivite DOM elements with only few data attributes.
In your HTML:
```
<div class="pi" data-component="base" data-pi="cont">...</div>
```
In your JS:
```
$("@cont").pi().show() // remove 'hidden' class if present
$("@cont").pi().hide() // add 'hidden' class 
$("@cont").pi().enable() // remove 'disabled' class and DOM attr if present
$("@cont").pi().disable() // add 'disabled' class and DOM attr 

$("@cont").pi().on("click",doSomething,this) // add event listener; custom events available too: "enabled", "visible"...
disposable listeners (i.e. "one(...)") also...
```
* Use CSS styles instead of DOM manipulations like ```display:none;```: 
every _piece_ automatically update class on state change ('hidden', 'disabled', 'selected', 'readonly', etc).
* Move all your logic to DOM! If you want...
In your HTML:
```
<div class="pi" data-component="base" data-pi="cont" data-event-visible="@btn.toggleVisible">...</div>
<a href="@cont.hide">Hide cont</a>
<button class="pi" data-pi="btn" data-option-hidden="true" data-component="button" data-event-click="@cont.show">Show cont</a>
```
In your JS:
```
nothin'
```
* Pieces (or _components_) from the box:
   - List: list of elements with built-in manipulation functions (add/remove/clear), template rendering (or DOM parsing), custom events ('item_click') and many useful plugins (Selectable, Searchable, Autoload, Sortable)
   - ...    
* *Slim* shortcuts to be done
* Some useful functions in _pi.utils_: 
  ```
   // Function currying
   function curry(fun,args,this){...} 

   // very common case
   var logger = {
    log: function(level,message){...}
    };
   
   logger.debug = curry('log','debug',logger);
   logger.stupid = curry(logger.log,['stupid','hello_world'],logger);

   // Delayed currying (yeah, kinda strange). Create function without call!
   function delayed(delay, fun, args, this){...}

   // Reversed setTimeout: call function after delay
   function after(delay, fun, this){...} 

   // Uniq string id
   function uuid(){...}

   // Camel case and snake case conversions
   pi.utils.camelCase("my_super_class") = "MySuperClass"
   pi.utils.snakeCase("MySuperClass") = "my_super_class"

   // email checking
   pi.utils.is_email("palkan@pieces.wtf") = true

   // string simple serialize
   pi.utils.serialize("true") = true
   pi.utils.serialize("12d") = "12d"
   pi.utils.serialize("1.5") = 1.5

   // beautiful colored, leveled and timed logging
   pi.utils.debug('something') // 2014-02-01 11:00:213 [debug] something (in green)
   pi.utils.error('something') // 2014-02-01 11:00:213 [error] something (in red)
   pi.utils.info('something') // 2014-02-01 11:00:213 [info] something (in blue)
   pi.utils.warning('something') // 2014-02-01 11:00:213 [warning] something (in orange)

   // set log level: debug <- info <- warning <- error 
   pi.log_level = "info"
    

   



