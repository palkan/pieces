'use strict'

import {Event} from './event'
import {EventListener} from './listener'

function _types(types){
  if(typeof types === 'string')
    return types.split(/\,\s*/)
  else if(Array.isArray(types))
    return types
  else
    return [null]
}

const TypeListener = {}

export class EventDispatcher {
  constructor(){
    this.listeners = {}
    this.listeners_by_key = {}
  }

  // API functions

  /**
  * Register new listener class for type.
  *
  * @param {String} type
  * @param {Function} klass 
  */
  static register_type_listener(type, klass){
    TypeListener[type] = klass
  }

  static unregister_type_listener(type){
    delete TypeListener[type]
  }

  /**
  * Attach listener for event types `types`.
  * Optionally provide context and events filtering function.
  *
  * @param {String, Array} types
  * @param {Function} callback
  * @param {Object} [context]
  * @param {Function} [filter]
  */
  on(types, callback, context = null, filter = null){
    for(let type of _types(types)){
      this.add_listener(type, callback, context, false, filter)
    }
  }

  /**
  * The same as `on` but attached listener would be triggered only once.
  *
  * @param {String, Array} types
  * @param {Function} callback
  * @param {Object} [context]
  * @param {Function} [filter]
  */
  one(types, callback, context = null, filter = null){
    for(let type of _types(types)){
      this.add_listener(type, callback, context, true, filter)
    }
  }

  /**
  * Remove listeners.
  * It is possible to remove specific listener (using handler function),
  * listeners by event type or all listeners.
  *
  * @example 
  *   // Remove all listeners for all events
  *   element.off()
  *
  *   // Remove all listeners of a type 'event'
  *   element.off('event')  
  *
  * @param {String, Null} [event]
  * @param {Function, Null} [callback]
  * @param {Object, Null} [context]
  */ 
  off(types, callback, context, conditions){
    for(let type of _types(types)){
      this.remove_listener(type, callback, context)
    }
  }


  /**
  * Trigger event
  *
  * @params {String, Object} event
  * @params [Object, Null] data data that will be passed with event as `event.data`
  * @params [Boolean] [bubbles]
  */
  trigger(event, data, bubbles = true){
    if(!(event instanceof Event)) event = new Event(event, this, bubbles)
    event.data = data
    event.currentTarget = this

    if(this.listeners[event.type]){
      for(let listener of this.listeners[event.type]){
        listener.dispatch(event)
        if(event.canceled) break 
      }
      this.remove_disposed_listeners()
    }
  
    if(!event.captured && event.bubbles) this.bubble_event(event)
  }

  // Internal functions

  bubble_event(_event) { /* overwrite this to implement custom bubbling */}

  add_listener(type, callback, context, disposable, filter){
    var listener = TypeListener[type]
                   ? new TypeListener[type](type, callback, context, disposable, filter)
                   : new EventListener(type, callback, context, disposable, filter)

    this.listeners[listener.type] = this.listeners[listener.type] || []
    this.listeners[listener.type].push(listener)
    this.listeners_by_key[listener.uid] = listener
  }

  remove_listener(type, callback, context){
    if(!type) return this.remove_all_listeners()
    
    if(!this.listeners[type]) return

    if(!callback) return this.remove_listeners_type(type)

    var uid = `${type}:${callback._uid}`

    if(context) uid += `:${context._uid}`

    var listener = this.listeners_by_key[uid]
    if(!listener) return

    listener.dispose()
    delete this.listeners_by_key[uid]
    this.remove_listener_from_list(type, listener)
  }

  remove_listener_from_list(type, listener){
    if(this.listeners[type] && (this.listeners[type].indexOf(listener) > -1)){
      this.listeners[type].splice(this.listeners[type].indexOf(listener), 1)
      if(!this.listeners[type].length) this.remove_listeners_type(type)
    }
  }

  remove_disposed_listeners(){
    var listener
    for(let key in this.listeners_by_key){
      listener = this.listeners_by_key[key]
      if(listener.disposed){
        this.remove_listener_from_list(listener.type, listener)
        delete this.listeners_by_key[key]
      }
    }
  }
        
  remove_listeners_type(type){
    for(let listener of this.listeners[type]){
      listener.dispose()
      delete this.listeners_by_key[listener.key]
    }
    delete this.listeners[type]
  }
  
  remove_all_listeners(){
    for(let type in this.listeners){
      this.remove_listeners_type(type)
    }
    this.listeners = {}
    this.listeners_by_key = {}
  }
}
