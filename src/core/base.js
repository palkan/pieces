"use strict";

let named = (name) => {
	return (target) => {
		target.my_name = name;
	};
};

let mixin = (mod) => {
	return (target) => {
		for(let name of Reflect.ownKeys(mod)) {
			let $super = target.prototype[name];
			target.prototype[name] = function(...args){
				args.push($super.bind(this))
				mod[name].apply(this, args);
			}
		}
	}
}

let MixinExample = {
	initialize($super) {
		$super()
		this._mixedin = true;
	}
}

let MixinExample2 = {
	initialize($super) {
		$super()
		this._mixedin2 = true;
	},

	dispose($super) {
		this._mixedin = false;
		this._mixedin2 = false;
		$super()
	}
}


@named('Base')
@mixin(MixinExample)
@mixin(MixinExample2)
export class Base {
	_initialiazed = false;
	_disposed = false;

	constructor() {
		this.initialize()
	}

	initialize() {
		this._initialiazed = true;
	}

	dispose() {
		this._disposed = true;
		this._initialiazed = false;
	}
}

