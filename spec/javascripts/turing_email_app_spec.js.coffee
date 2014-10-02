describe "TuringEmailApp", ->
  describe "#moveTuringEmailReportToTop", ->
  
    describe "if there is a report email", ->
  
      beforeEach ->
        @turingEmailThread = _.values(@listView.listItemViews)[0].model
  
        @listView.collection.remove @turingEmailThread
        @turingEmailThread.get("emails")[0].from_name = "Turing Email"
        @listView.collection.add @turingEmailThread
  
      it "should move the email to the top", ->
        expect($("#email_table_body").children()[0]).not.toContainText("Turing Email")
  
        @listView.moveTuringEmailReportToTop()
  
        expect($("#email_table_body").children()[0]).toContainText("Turing Email")
  
    describe "if there is not a report email", ->
  
      it "should leave the emails in the same order", ->
        emailTableBodyBefore = $("#email_table_body")
        @listView.moveTuringEmailReportToTop()
        emailTableBodyAfter = $("#email_table_body")
  
        expect(emailTableBodyBefore).toEqual emailTableBodyAfter