import * as _ from '../../../src/core/utils/object'

describe('object utils', () => {
  describe('#extend', () => {
    it('extends object', () => {
      var target = { a: 1, b: 2 }
      var extended = _.extend(target, { b: 3, c: 4 })
      expect(extended).toBe(target)
      expect(target.b).toEqual(2)
      expect(target.c).toEqual(4)
    })

    it('extends with overwrite', () => {
      var target = { a: 1, b: 2 }
      _.extend(target, { b: 3, c: 4 }, { overwrite: true })
      expect(target.b).toEqual(3)
      expect(target.c).toEqual(4) 
    })

    it('extends with except', () => {
      var target = { a: 1 }
      _.extend(target, { b: 3, c: 4 }, { except: ["c"] })
      expect(target.b).toEqual(3)
      expect(target.c).toBeUndefined()
    })

    it('extends with only', () => {
      var target = { a: 1, b: 2 }
      _.extend(target, { b: 3, c: 4 }, { only: ["c"] })
      expect(target.c).toEqual(4)
      expect(target.b).toEqual(2)
      expect(target.a).toEqual(1)
    })
  })

  describe('#extract', () => {
    let source = { 
      id: 14,
      name: "A", 
      tags: [
        { name: "cool", id: 1, type: "private" },
        { name: "hot", id: 2, type: "public" }
      ], 
      user: {
        id: 123, 
        photo: {
          url: "http://image",
          thumb: "http://thumb"
        }
      }
    }

    it("extracts top-level values", () => {
      var res = _.extract(source, ['id', 'user'])
      expect(res.id).toEqual(14)
      expect(res.user).toHaveMember('id', 'photo')
    })

    it("extracts with subobjects filter values", () => {
      var res = _.extract(source, ['id', { tags: ['id'] }, { user: [{ photo: 'thumb' }]}])
      expect(res.id).toEqual(14)
      expect(res.user.id).toBeUndefined()
      expect(res.tags.length).toEqual(2)
      expect(res.tags[0].id).toEqual(1)
      expect(res.tags[0].name).toBeUndefined()
      expect(res.tags[0].type).toBeUndefined()
      expect(res.user.id).toBeUndefined()
      expect(res.user.photo.url).toBeUndefined()
      expect(res.user.photo.thumb).toEqual('http://thumb')
    })
  })
})