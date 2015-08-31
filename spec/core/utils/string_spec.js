import * as _ from '../../../src/core/utils/string'

describe('string utils', () => {
  describe("#camelize", () => {
    it("works with one word", () => {
      expect(_.camelize("worm")).toEqual("Worm")
    })

    it("works with a few words", () => {
      expect(_.camelize("little_camel_in_the_desert")).toEqual("LittleCamelInTheDesert")
    })
  })
 
  describe("#underscore", () => {
    it("works with a few words", () => {
      expect(_.underscore("CamelSong")).toEqual("camel_song")
    })

    it("works with non-capitalized word", () => {
      expect(_.underscore("camelSong")).toEqual("camel_song")
    })
  })

  describe("#serialize", () => {
    it("recognizes bool", () => {
      expect(_.serialize("true")).toBeTruthy()
      expect(_.serialize("false")).toBeFalsy()
    })

    it("recognizes empty string", () => {
      expect(_.serialize("")).toEqual("")
    })

    it("recognizes null as string", () => {
      expect(_.serialize("null")).toBeNull()
    })

    it("recognizes undefined as string", () => {
      expect(_.serialize("undefined")).toBeUndefined()
    })

    it("recognizes integer number", () => {
      expect(_.serialize("123")).toEqual(123)
    })

    it("recognizes float number", () => {
      expect(_.serialize("2.6")).toEqual(2.6)
    })

    it("recognizes string", () => {
      expect(_.serialize("123m535.35")).toEqual("123m535.35") 
    })

    it("retruns null on void", () => {
      expect(_.serialize(undefined)).toBeNull()
      expect(_.serialize(null)).toBeNull()
    })
  })

  describe("#squish", () => {
    it("multiline", () => {
      let s = ` Multi-line
        string
        `
      expect(_.squish(s)).toEqual('Multi-line string')
    })

    it("tabs and spaces", () => {
      let s = '  foo   bar    \n   \t   boo '
      expect(_.squish(s)).toEqual('foo bar boo')
    })
  })

  describe("#strip_quotes", () => {
    it("single quotes", () => {
      expect(_.strip_quotes("'bla'")).toEqual('bla')
    })

    it("double quotes", () => {
      expect(_.strip_quotes('"bla"')).toEqual('bla')
    })

    it("different quotes", () => {
      expect(_.strip_quotes("'bla\"")).toEqual("'bla\"")
    })

    it("no quotes", () => {
      expect(_.strip_quotes("bl'a")).toEqual("bl'a")
    })
  })

  describe('#capitalize', () => {
    it('convert lower case to upper case', () => {
      expect(_.capitalize('abc')).toBe('Abc')
    })
  })
})
