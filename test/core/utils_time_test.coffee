'use strict'
TestHelpers = require './helpers'

describe "pieces time utils", ->
  describe "format time", ->

    date = new Date('Jun 17 2014')
    # PhantomsJS date parsing differs from others, so set time manually
    date.setHours(12)
    date.setMinutes(54)
    date.setSeconds(25)
    date.setMilliseconds(22)
    date2 = new Date('Jun 07 2014')
    date2.setHours(13)
    date2.setMinutes(4)
    date2.setSeconds(5)
    date2.setMilliseconds(2)


    it "should work", ->
      expect(pi.utils.time.format(date, "%Y-%m-%d")).to.equal "2014-06-17"
      expect(pi.utils.time.format(date, "%H:%M:%S:%L")).to.equal "12:54:25:022"
      expect(pi.utils.time.format(date, "Today is %d/%m/%y")).to.equal "Today is 17/06/14"
      expect(pi.utils.time.format(date, "Full date %Y-%m-%d %I:%M:%S %P is ok")).to.equal "Full date 2014-06-17 12:54:25 PM is ok"
      expect(pi.utils.time.format(date2, "Full date2 %Y-%m-%d %l:%M:%S %p is ok")).to.equal "Full date2 2014-06-07 1:04:05 pm is ok"
      expect(pi.utils.time.format(date, "%Y%m%d %H%k%M%S%L %I%l %P%p")).to.equal "20140617 12125425022 1212 PMpm"
      expect(pi.utils.time.format(date2, "%Y%m%d %H%k%M%S%L %I%l %P%p")).to.equal "20140607 13130405002 011 PMpm"