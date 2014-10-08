describe "TDate", ->

  describe "#constructor", ->

    it "should take a date object in the constructor", ->
      d = new Date()
      tDate = new TDate(d)
      expect(tDate.date).toEqual d

  describe "#initializeWithISO8601", ->

    it "should initialize the tdate object with an ISO 8601 date string", ->
      tDate = new TDate()
      tDate.initializeWithISO8601("2014-09-18T21:28:48.000Z")
      expect(tDate.date.toString()).toEqual "Thu Sep 18 2014 14:28:48 GMT-0700 (PDT)"

  describe "#longFormDateString", ->

    it "should produce a correctly formatted date string", ->
    tDate = new TDate()
    tDate.initializeWithISO8601("2014-09-18T21:28:48.000Z")
    expect(tDate.longFormDateString()).toEqual "Thu, Sep 18, 2014 at 2:28 PM"
