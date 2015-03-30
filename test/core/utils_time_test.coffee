'use strict'
h = require 'pieces/test/helpers'
utime = pi.utils.time

describe "Utils", ->
  describe "Time", ->
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

    describe "format", ->
      it "format number", ->
        expect(utime.format(ts1,'%Y-%m-%d')).to.eq "2015-06-01"
        expect(utime.format(ts1/1000,'%Y-%m-%d')).to.eq "2015-06-01"

      it "format string", ->
        expect(utime.format("2015-06-01",'%d.%m.%Y')).to.eq "01.06.2015"
        expect(utime.format("Jun 1 2015",'%Y-%m-%d')).to.eq "2015-06-01"

      it "format date", ->
        expect(utime.format(date, "%Y-%m-%d")).to.equal "2014-06-17"
        expect(utime.format(date, "%H:%M:%S:%L")).to.equal "12:54:25:022"
        expect(utime.format(date, "Today is %d/%m/%y")).to.equal "Today is 17/06/14"
        expect(utime.format(date, "Full date %Y-%m-%d %I:%M:%S %P is ok")).to.equal "Full date 2014-06-17 12:54:25 PM is ok"
        expect(utime.format(date2, "Full date2 %Y-%m-%d %l:%M:%S %p is ok")).to.equal "Full date2 2014-06-07 1:04:05 pm is ok"
        expect(utime.format(date, "%Y%m%d %H%k%M%S%L %I%l %P%p")).to.equal "20140617 12125425022 1212 PMpm"
        expect(utime.format(date2, "%Y%m%d %H%k%M%S%L %I%l %P%p")).to.equal "20140607 13130405002 011 PMpm"

    describe "duration", ->
      it "with seconds", ->
        expect(utime.duration(61)).to.eq "0:01:01"
        expect(utime.duration(12+60*23+60*60*123)).to.eq "123:23:12"

      it "with milliseconds", ->
        expect(utime.duration(61032,true)).to.eq "0:01:01"
        expect(utime.duration(61000,true,true)).to.eq "0:01:01.000"
        expect(utime.duration(1+(12+60*23+60*60*123)*1000,true,true)).to.eq "123:23:12.001"

    describe "add_formatter", ->
      it "works", ->
        utime.add_formatter('E', (d) -> if d.getDate() % 2 == 0 then 'even' else 'odd')
        expect(utime.format(date2, "%e is %E")).to.eq "7 is odd" 
        expect(utime.format(new Date('Jul 14 1957'), "%e is %E")).to.eq "14 is even" 