class TuringEmailApp.Views.ToolbarView extends Backbone.View
  template: JST["backbone/templates/toolbar_view"]
  tagName: "div"

  remove: ->
    @$el.remove()

  setup_toolbar_buttons: ->
    @setup_read()
    @setup_trash()
    @setup_go_left()
    @setup_go_right()

  setup_read: ->
    @$el.find("i.fa-eye").parent().click ->
      console.log "mark as read"

  setup_trash: ->
    @$el.find("i.fa-trash-o").parent().click ->
      console.log "trash"

  setup_go_left: ->
    @$el.find("#paginate_left_link").click ->
      windowSearchAttribute = window.location.search
      if windowSearchAttribute != ""
        currentPageNumber = windowSearchAttribute.split("page=")[1]
        newPageNumber = parseInt(currentPageNumber) - 1
        if newPageNumber >= 1
          newUrl = "?page=" + newPageNumber.toString()
          window.location = newUrl

    @$el.find("#paginate_left_link").click ->
      console.log window.location.search
      if windowSearchAttribute != ""
        currentPageNumber = windowSearchAttribute.split("page=")[1]
      else
        currentPageNumber = "1"
      newPageNumber = parseInt(currentPageNumber) + 1
      newUrl = "?page=" + newPageNumber.toString()
      window.location = newUrl

  setup_go_right: ->
    @$el.find("#paginate_right_link").click ->
      windowSearchAttribute = window.location.search
      if windowSearchAttribute != ""
        currentPageNumber = windowSearchAttribute.split("page=")[1]
      else
        currentPageNumber = "1"
      newPageNumber = parseInt(currentPageNumber) + 1
      newUrl = "?page=" + newPageNumber.toString()
      console.log newUrl
      window.location = newUrl

  render: ->
    @$el.html(@template())
    @setup_toolbar_buttons()
    return this
