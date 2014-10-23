FactoryGirl.define "EmailThread", ->
  @sequence("id", "uid") 
  @emails = FactoryGirl.createLists("Email", FactoryGirl.SMALL_LIST_SIZE)