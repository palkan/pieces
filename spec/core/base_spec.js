"use strict";

import {Base} from "src/core/base";

describe('Base', () => {
	it("has name", () => {
		expect(Base.my_name).toEqual("Base");
	})

	it("calls super", () => {
		let obj = new Base()
		expect(obj._initialiazed).toBeTrue()
		expect(obj._mixedin).toBeTrue()
		expect(obj._mixedin2).toBeTrue()
		
		obj.dispose()
		expect(obj._initialiazed).toBeFalse()
		expect(obj._mixedin).toBeFalse()
		expect(obj._mixedin2).toBeFalse()
		expect(obj._disposed).toBeTrue()
	})
});