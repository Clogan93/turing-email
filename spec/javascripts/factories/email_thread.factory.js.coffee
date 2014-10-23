FactoryGirl.define "EmailThread", ->
  @sequence("id", "uid") 
  @emails = FactoryGirl.createLists("Email", FactoryGirl.SMALL_LIST_SIZE)

  @from_name = "Allan"
  @from_address = "allan@turing.com"
  @date = new Date()
  @subject = "Subject"
  
  @snippet = "snippet"
  @folder_ids = ["Test"]
  @seen = false

  @loaded = true