class @Report

  constructor: (view) ->
    @view = view

  setupContainers: ->
    @view.$el.find(".collapse-link").click ->
      # TODO test what happens upon click.
      ibox = $(this).closest("div.ibox")
      button = $(this).find("i")
      content = ibox.find("div.ibox-content")

      content.slideToggle 200
      button.toggleClass("fa-chevron-up").toggleClass "fa-chevron-down"
      ibox.toggleClass("").toggleClass "border-bottom"

      setTimeout (->
        ibox.resize()
        ibox.find("[id^=map-]").resize()
        return
      ), 50

      return

    @view.$el.find(".close-link").click ->
      # TODO test what happens upon click.
      content = $(this).closest("div.ibox")
      content.remove()
      return
