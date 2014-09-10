describe "Attachments report model", ->

  beforeEach ->
    @attachments_report = new TuringEmailApp.Models.AttachmentsReport()

  it "should exist", ->
    expect(TuringEmailApp.Models.AttachmentsReport).toBeDefined()

  it "should have the right url", ->
    expect(@attachments_report.url).toEqual '/api/v1/emails/attachments_report'
