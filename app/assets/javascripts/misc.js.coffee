window.getQuerystringNameValue = (name) ->
  
  # For example... passing a name parameter of "name1" will return a value of "100", etc.
  # page.htm?name1=100&name2=101&name3=102
  winURL = window.location.href
  queryStringArray = winURL.split("?")
  return null  if queryStringArray.length < 2
  queryStringParamArray = queryStringArray[1].split("&")
  nameValue = null
  i = 0

  while i < queryStringParamArray.length
    queryStringNameValueArray = queryStringParamArray[i].split("=")
    nameValue = queryStringNameValueArray[1]  if name is queryStringNameValueArray[0]
    i++
  nameValue
