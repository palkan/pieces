'use strict'
TestHelpers = require './helpers'
utils = pi.utils

describe "pieces utils", ->
  describe "time utils", ->
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

      ts1 = +new Date('Jun 1 2015')
      
      it "should work with utc ts", ->
        expect(utils.time.format(ts1,'%Y-%m-%d')).to.eq "2015-06-01"
        expect(utils.time.format(ts1/1000,'%Y-%m-%d')).to.eq "2015-06-01"

      it "should work with string", ->
        expect(utils.time.format("2015-06-01",'%d.%m.%Y')).to.eq "01.06.2015"
        expect(utils.time.format("Jun 1 2015",'%Y-%m-%d')).to.eq "2015-06-01"

      it "should work with date object", ->
        expect(utils.time.format(date, "%Y-%m-%d")).to.equal "2014-06-17"
        expect(utils.time.format(date, "%H:%M:%S:%L")).to.equal "12:54:25:022"
        expect(utils.time.format(date, "Today is %d/%m/%y")).to.equal "Today is 17/06/14"
        expect(utils.time.format(date, "Full date %Y-%m-%d %I:%M:%S %P is ok")).to.equal "Full date 2014-06-17 12:54:25 PM is ok"
        expect(utils.time.format(date2, "Full date2 %Y-%m-%d %l:%M:%S %p is ok")).to.equal "Full date2 2014-06-07 1:04:05 pm is ok"
        expect(utils.time.format(date, "%Y%m%d %H%k%M%S%L %I%l %P%p")).to.equal "20140617 12125425022 1212 PMpm"
        expect(utils.time.format(date2, "%Y%m%d %H%k%M%S%L %I%l %P%p")).to.equal "20140607 13130405002 011 PMpm"

    describe "duration", ->
      it "should work with seconds", ->
        expect(utils.time.duration(61)).to.eq "0:01:01"
        expect(utils.time.duration(12+60*23+60*60*123)).to.eq "123:23:12"

      it "should work with milliseconds", ->
        expect(utils.time.duration(61032,true)).to.eq "0:01:01"
        expect(utils.time.duration(61000,true,true)).to.eq "0:01:01.000"
        expect(utils.time.duration(1+(12+60*23+60*60*123)*1000,true,true)).to.eq "123:23:12.001"