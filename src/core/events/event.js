import * as _ from '../utils'

/**
* Base event class
*/ 
export class Event {
  constructor(event, target, bubbles = true){
    if(event && (typeof event === "object"))
      _.extend(this, event)
    else
      this.type = event

    if(!this.type) throw Error("Event type is required")

    this.target = target
    this.bubbles = bubbles
    this.canceled = false
    this.captured = false
  }

  cancel(){
    this.canceled = true  
  }
}
