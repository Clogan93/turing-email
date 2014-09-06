class TuringEmailApp.Views.ToolbarView extends Backbone.View
  template: JST["backbone/templates/toolbar_view"]
  tagName: "div"

  remove: ->
    @$el.remove()

  setup_toolbar_buttons: ->
    @.setup_read()
    @.setup_trash()
    @.setup_go_left()
    @.setup_go_right()

  setup_read: ->
    @$el.find("i.fa-eye").parent().click ->
      console.log "mark as read"

  setup_trash: ->
    @$el.find("i.fa-trash-o").parent().click ->
      console.log "trash"

  setup_go_left: ->
    @$el.find("i.fa-arrow-left").parent().click ->
      console.log "paginate left"

  setup_go_right: ->
    @$el.find("i.fa-arrow-right").parent().click ->
      console.log "paginate right"

  render: ->
    @$el.html(@template())
    @.setup_toolbar_buttons()
    return this
