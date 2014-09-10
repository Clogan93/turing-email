describe "Email volume report model", ->

  beforeEach ->
    @email_volume_report = new TuringEmailApp.Models.EmailVolumeReport()

  it "should exist", ->
    expect(TuringEmailApp.Models.EmailVolumeReport).toBeDefined()

  it "should have the right url", ->
    expect(@email_volume_report.url).toEqual '/api/v1/emails/volume_report'
