'use strict';

/**
* Returns new array without matching elements.
* 
* @param {Array} arr
* @param ...values
*
* @example
*
*   without(['a', 'b', 'c', 'c', 'd'], 'b', 'c') #=> ['a', 'd']
*/
export function without(arr, ...values){
  let filterFun = (item) => { return !(values.indexOf(item) > -1) }
  return arr.filter(filterFun);
}
