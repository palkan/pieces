'use strict'
import {parser} from './parser';
import * as _ from '../core/utils';

const ERROR_FUN = function(fun_str){
  _.error(`Function [${fun_str}] was compiled with error`);
  return false;
}

const OPERATORS = {
  ">": ">",
  "<": "<",
  "=": "=="
};

const nodCache = new WeakMap();

/**
* Parse function string and convert to callable.
*
* Possible node codes:
*   chain - get method chain res ('app.view.hide(true)')
*   prop - get object property ('app')
*   call - call object fun ('hide(true)')
*   if - get conditinal call res ('e.data ? show() : hide()')
*   op - operator ('1+1')
*   logic - logical expressions ('a > b')
*   res - get resource ('User')
*   simple - constant value
*/
class CompiledFun{
  /**
  * Create new function
  *
  * @param {*} Execution context ('this')
  * @param {Object} AST function representation
  */
  constructor(target, ast){
    this.target = target || {};
    this.ast = ast;
  }

  static compile(ast){
    let source = Compiler.ast_to_str(ast, '__res = ');

    source = `
      var _ref, __res, _args = arguments;
      ${source};
      return __res;
      //# sourceURL=/pi_compiled/source_${_.uid()};\n
    `
    return new Function(source);
  }

  call(ths, ...args){
    return this.apply(ths, args);
  }

  apply(ths, args){
    this.call_ths = ths || {};
    return this.compiled.apply(this, args);
  }

  get compiled(){
    return this._compiled || (this._compiled = CompiledFun.compile(this.ast));
  }
}

export class Compiler {
  /** 
  * Used to overwrite chain target for compiled function:
  *
  * @example
  *   "this.id" => "this.target.id"
  *   // for event handlers
  *   Compile.global_targets["event"] = "_args[0]"
  */
  static MODIFIERS = {
    "this": "this.target",
    "window": "window"
  }

  /**
  * Contains processors for different AST node types.
  */
  static NODE_HANDLERS = {}

  static parse(str){
    return parser.parse(str);
  }

  // Traverse AST and call callback on each node
  static traverse(ast, callback){
    callback.call(null, ast);

    if((ast.left != void 0) && (ast.right != void 0)){
      this.traverse(ast.left, callback);
      this.traverse(ast.right, callback);

      if(ast.code === 'if')
        this.traverse(ast.cond, callback);

    }else if(ast.code  === 'chain'){
      ast.value.map((val) => { this.traverse(val, callback) });

    }else if(ast.code === 'call'){
      ast.args.map((val) => { this.traverse(val, callback) });
    }
  }

  static compile(str, target){
    let ast = (typeof str === 'string' ? this.parse(str) : str);
    return new CompiledFun(target, ast);
  }

  static ast_to_str(ast, source = ''){
    return this.NODE_HANDLERS[ast.code](ast, source);
  }

  static build_safe_call(data, source = ''){
    let method = `${source}['${data.name}']`;
    return `
      ((typeof ${method} === 'function') ? ${method}(${Compile.build_args(data.args)}) : null)
    `;
  }

  static build_args(args){
    return args.map((arg) => { return Compiler.ast_to_str(arg) }).join(', ');
  }

  static quote(val){
    if(typeof val === 'string')
      return `'${val}'`;
    else if(val && (typeof val === 'object'))
      return `JSON.parse('${JSON.stringify(val)}')`;
    else
      return val;
  }
}

Compiler.NODE_HANDLERS['chain'] = function(data, source){
  let frst = data.value[0];

  if(frst.code === 'prop' || frst.code === 'res'){
    if(Compiler.MODIFIERS[frst.name]){
      source += Compiler.MODIFIERS[frst.name];
    }else{
      source += `
        (function(){
          _ref = (${Compiler.ast_to_str(frst, 'this.call_ths')});
          if(!(_ref == void 0)) return _ref;
          _ref = this.target.scoped && (${Compiler.ast_to_str(frst, 'this.target.scope')});
          if(this.target.scoped && !(_ref == void 0)) return _ref;

          return (${Compiler.ast_to_str(frst, 'window')});
        }).call(this)
      `;
    }
  }
  // otherwise it's a call
  else{
    source += `
      (function(){
        _ref = ${Compiler.build_safe_call(frst, 'this.call_ths')};
        if(!(_ref == void 0)) return _ref;
        _ref = this.target.scoped && ${Compiler.build_safe_call(frst, 'this.target.scope.scope')};
        if(this.target.scoped && !(_ref == void 0)) return _ref;
        _ref = this.target.scoped && ${Compiler.build_safe_call(frst, 'this.target')};
        if(!(_ref == void 0)) return _ref;
        return ${Compiler.build_safe_call(frst, 'window')};
      }).call(this)
    `;
  }

  return data.value.slice(1).reduce(
    (str, step) => {
      return str = Compiler.ast_to_str(step, str)
  }, source);
};

Compiler.NODE_HANDLERS['prop'] = function(data, source){
  return `${source}.${data.name}`;
};


Compiler.NODE_HANDLERS['call'] = function(data, source){
  return `${source}.${data.name}(${Compiler.build_args(data.args)})`;
};

Compiler.NODE_HANDLERS['op'] = function(data, source){
  let type = data.type === '=' ? '==' : data.type;

  return `${source}(${Compiler.ast_to_str(data.left)}) ${type} (${Compiler.ast_to_str(data.right)})`;
};

Compiler.NODE_HANDLERS['if'] = function(data, source){
  source += '(function(){';

  source += `if(${Compiler.ast_to_str(data.cond)})`;
  
  source +=`
    {
      return (${Compiler.ast_to_str(data.left)});
    }
  `;

  if(data.right != void 0)
    source += `else{ return (${Compiler.ast_to_str(data.right)});}`;
  
  return `${source}}).call(this);`
};
 
Compiler.NODE_HANDLERS['simple'] = function(data, source){
  return `${source}${Compiler.quote(data.value)}`;
};

Compiler.NODE_HANDLERS['logic'] = function(data, source){
  return `${source}(${Compiler.ast_to_str(data.left)}) ${data.type} (${Compiler.ast_to_str(data.right)})`;
};
