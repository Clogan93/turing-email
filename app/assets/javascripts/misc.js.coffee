window.base64_decode_urlsafe = (data) ->
  return atob(data.replace(/-/g,'+').replace(/_/g,'/'))
