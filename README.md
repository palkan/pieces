# JS Pieces
Create interactive pages without writing any javascript (or maybe just a little piece of code).
Use basic pieces or create your own on top of them. 

## Deps
No more deps! 

## Dev Deps
NodeJS+Bower+Brunch

## Features 
* Interactivite DOM elements with only few data attributes.
In your HTML:
```
<div class="pi" pid="cont">...</div>
```
In your JS:
```
$("@cont").show() // remove 'hidden' class if present
$("@cont").hide() // add 'hidden' class 
$("@cont").enable() // remove 'disabled' class and DOM attr if present
$("@cont").disable() // add 'disabled' class and DOM attr 

$("@cont").on("click",doSomething,this) // add event listener; custom events available too: "enabled", "visible"...
disposable listeners (i.e. "one(...)") also...
```

**Note**: ``$`` is not JQuery; it's just a shortcut to:
- search through components (using '@' prefix);
- search DOM (using usual CSS queries, but return only the first matching element);
- create DOM elements from HTML string

* Use CSS styles instead of DOM manipulations like ```display:none;```: 
every _piece_ automatically update class on state change ('hidden', 'disabled', 'selected', 'readonly', etc).
* *Call queries* Move all your logic to DOM! If you want...
In your HTML:
```
<div class="pi" pid="cont" data-on-hidden=" e.data ? @btn.show : @btn.hide">...</div>
<a href="@cont.hide">Hide cont</a>
<a href="@cont.show">Show cont</a>
```
In your JS:
```
nothin'
```

And even more:
```
// use 'this' keyword in call query
<div class="pi" data-on-click="@this.hide">...</div>

// use 'host' keyword in call query (host is parent component (not DOM element))
<div class="pi" data-on-click="@host.hide">...</div>


// binding
<input class="pi" type="text" data-on-blur="@list.search(@this.value)"/>
```

* Pieces (or _components_) from the box:
   - List: list of elements with built-in manipulation functions (add/remove/clear), template rendering (JST, Mustache) or DOM parsing, custom events ('item_click') and many useful plugins (Selectable, Searchable, Scrollend, Sortable, MoveSelect, Filterable);
   - FileInput
   - SelectInput
   - SearchInput
   - ...

* RVC - resources-view-controller logic.
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
   function uid(){...}

   // Camel case and snake case conversions
   pi.utils.camelCase("my_super_class") = "MySuperClass"
   pi.utils.snake_case("MySuperClass") = "my_super_class"


   // email checking
   pi.utils.is_email("palkan@pieces.wtf") = true


   // string simple serialize
   pi.utils.serialize("true") = true
   pi.utils.serialize("12d") = "12d"
   pi.utils.serialize("1.5") = 1.5

   // array sort (using Array.sort)
   pi.utils.sort(arr,sort_params) // by multiple keys 
   
   pi.utils.sort(arr, [{date:'asc'},{name:'desc'}])

   pi.utils.sort_by(arr,key,order)

   // deep cloning (clones Node elements too)
   pi.utils.clone(data)

   // beautiful colored, leveled and timed logging
   pi.utils.debug('something') // 2014-02-01 11:00:213 [debug] something (in green)
   pi.utils.error('something') // 2014-02-01 11:00:213 [error] something (in red)
   pi.utils.info('something') // 2014-02-01 11:00:213 [info] something (in blue)
   pi.utils.warning('something') // 2014-02-01 11:00:213 [warning] something (in orange)

   // set log level: debug <- info <- warning <- error 
   pi.log_level = "info"
   
   // time format
   pi.utils.time.format(new Date(), '%Y-%m-%d %H:%M:%S') // 2014-06-19 20:05:33   

   



