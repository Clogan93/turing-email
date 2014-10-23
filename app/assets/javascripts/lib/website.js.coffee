class @WebsitePreview

  constructor: (url) ->
    @url = url
    @html = null

    $.ajax
      url: @url
      type: 'GET'
      complete: (data) =>
        @html = data.responseText

  title: ->
    return @html.match(/<title>(.*?)<\/title>/)[0]

  snippet: ->
    return @html.match(/<meta name="Description" content="(.*?)" \/>/)[0]

  image: ->
    return @html.match(/<meta property="og:image" content="(.*?)" \/>/)[0]
