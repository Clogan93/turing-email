FactoryGirl.define "DelayedEmail", ->
  @sequence("id", "uid")
  @subject = "Subject"
  @send_dat = new Date().toJSON()
