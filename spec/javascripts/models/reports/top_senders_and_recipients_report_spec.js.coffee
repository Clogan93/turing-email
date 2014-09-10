describe "Top senders and recipients report model", ->

  beforeEach ->
    @top_senders_and_recipients_report = new TuringEmailApp.Models.TopSendersAndRecipientsReport()

  it "should exist", ->
    expect(TuringEmailApp.Models.TopSendersAndRecipientsReport).toBeDefined()

  it "should have the right url", ->
    expect(@top_senders_and_recipients_report.url).toEqual '/api/v1/emails/contacts_report'
