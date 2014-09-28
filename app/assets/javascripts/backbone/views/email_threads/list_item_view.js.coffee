TuringEmailApp.Views.EmailThreads ||= {}

class TuringEmailApp.Views.EmailThreads.ListItemView extends Backbone.View
  template: JST["backbone/templates/email_threads/list_item"]
  tagName: "TR"

  initialize: ->
    @listenTo(@model, "change", @render)
    @listenTo(@model, "hide destroy", @remove)

  render: ->
    if @model.get("emails")[0].seen
      @$el.addClass("read")
    else
      @$el.addClass("unread")

    @$el.css({ cursor: "pointer" });

    modelJSON = @model.toJSON()
    modelJSON["fromPreview"] = @model.fromPreview()
    modelJSON["subjectPreview"] = @model.subjectPreview()
    @$el.html(@template(modelJSON))

    @setupClick()
    
    return this
    
  addedToDOM: ->
    @setupCheckbox()

  setupClick: ->
    tds = @$el.find('td.check-mail, td.mail-contact, td.mail-subject, td.mail-date')
    tds.click (event) =>
      @trigger("click", @)

  setupCheckbox: ->
    @$el.find(".i-checks").iCheck
      checkboxClass: "icheckbox_square-green"
      radioClass: "iradio_square-green"

    @$el.find("div.icheckbox_square-green ins").click (event) =>
      @toggleSelect()

  toggleSelect: ->
    diviCheck = $(event.target).parent()
    if diviCheck.hasClass "checked" then @select() else @deselect()

  select: ->
    diviCheck = @$el.find("div.icheckbox_square-green")

    diviCheck.iCheck("check")
    @$el.addClass("checked_email_thread")
    @trigger("selected", @)

  deselect: ->
    diviCheck = @$el.find("div.icheckbox_square-green")

    diviCheck.iCheck("uncheck")
    @$el.removeClass("checked_email_thread")
    @trigger("deselected", @)

  highlight: ->
    @$el.removeClass("read")
    @$el.removeClass("unread")
    @$el.addClass("currently_being_read")

    @trigger("highlight", @)

  unhighlight: ->
    @$el.removeClass("currently_being_read")

    @trigger("unhighlight", @)
    
  markRead: ->
    @$el.removeClass("unread")
    @$el.addClass("read")

    @trigger("markRead", @)

  markUnread: ->
    @$el.removeClass("read")
    @$el.addClass("unread")

    @trigger("markUnread", @)
