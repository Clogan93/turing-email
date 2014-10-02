describe "#getQuerystringNameValue", ->
  it "returns the value of the query parameter with the specified name", ->
    file = getQuerystringNameValue("file")
    