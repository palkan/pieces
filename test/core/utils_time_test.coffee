TestHelpers = require './helpers'

describe "pieces time utils", ->
  describe "format time", ->

    date = new Date(1402995265022) # Tue Jun 17 2014 12:54:25:022 GMT+0400
    date2 = new Date(1402131845002) # Tue Jun 07 2014 01:04:05:002 PM GMT+0400


    it "should work", ->
      expect(pi.utils.time.format(date, "%Y-%m-%d")).to.equal "2014-06-17"
      expect(pi.utils.time.format(date, "%H:%M:%S:%L")).to.equal "12:54:25:022"
      expect(pi.utils.time.format(date, "Today is %d/%m/%y")).to.equal "Today is 17/06/14"
      expect(pi.utils.time.format(date, "Full date %Y-%m-%d %I:%M:%S %P %z is ok")).to.equal "Full date 2014-06-17 12:54:25 PM +04:00 is ok"
      expect(pi.utils.time.format(date2, "Full date2 %Y-%m-%d %l:%M:%S %p %z is ok")).to.equal "Full date2 2014-06-07 1:04:05 pm +04:00 is ok"
      expect(pi.utils.time.format(date, "%Y%m%d %H%k%M%S%L %I%l %P%p %z")).to.equal "20140617 12125425022 1212 PMpm +04:00"
      expect(pi.utils.time.format(date2, "%Y%m%d %H%k%M%S%L %I%l %P%p %z")).to.equal "20140607 13130405002 011 PMpm +04:00"