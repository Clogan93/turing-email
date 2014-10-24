class @WebsitePreview

  constructor: (url) ->
    @url = url
    @html = null

    $.ajax
      url: "http://localhost:4000/api/v1/website_previews/proxy?url=" + @url
      type: 'GET'
      async: false
      complete: (data) =>
        @html = data.responseText

  title: ->
    return @html.match(/<title>(.*?)<\/title>/)?[0]?.replace("<title>", "")?.replace("</title>", "")

  snippet: ->
    return @html.match(/<meta name="Description" content="(.*?)" \/>/)?[0]?.replace('<meta name="Description" content="', "")?.replace('" />', "")

  image: ->
    return @html.match(/<meta property="og:image" content="(.*?)" \/>/)?[0]?.replace('<meta property="og:image" content="', "")?.replace('" />', "")
