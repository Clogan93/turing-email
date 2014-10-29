describe "EmailFolder", ->
  beforeEach ->
    @emailFolder = new TuringEmailApp.Models.EmailFolder(FactoryGirl.create("EmailFolder"))

  it "uses label_id as idAttribute", ->
    expect(@emailFolder.idAttribute).toEqual("label_id")
