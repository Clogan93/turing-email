TuringEmailApp.Views.EmailThreads ||= {}

class TuringEmailApp.Views.EmailThreads.ListItemView extends Backbone.View
  template: JST["backbone/templates/email_threads/list_item"]
  tagName: "TR"

  initialize: ->
    @listenTo(@model, "change", @render)
    @listenTo(@model, "removedFromCollection destroy", @remove)

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
      @trigger("click", this)

  setupCheckbox: ->
    @$el.find(".i-checks").iCheck
      checkboxClass: "icheckbox_square-green"
      radioClass: "iradio_square-green"

    @diviCheck = @$el.find("div.icheckbox_square-green")
    
    @$el.find("div.icheckbox_square-green ins").click (event) =>
      @updateSelectionStyles()

      if @diviCheck.hasClass "checked"
        @trigger("selected", this)
      else
        @trigger("deselected", this)

  updateSelectionStyles: ->
    if @diviCheck.hasClass "checked"
      @$el.addClass("checked_email_thread")
    else
      @$el.removeClass("checked_email_thread")
      
  toggleSelect: ->
    if @diviCheck.hasClass "checked" then @deselect() else @select()
    
  select: ->
    @diviCheck.iCheck("check")
    @updateSelectionStyles()
    
    @trigger("selected", this)

  deselect: ->
    @diviCheck.iCheck("uncheck")
    @updateSelectionStyles()
    
    @trigger("deselected", this)

  highlight: ->
    @$el.removeClass("read")
    @$el.removeClass("unread")
    @$el.addClass("currently_being_read")

    @trigger("highlight", this)

  unhighlight: ->
    @$el.removeClass("currently_being_read")

    @trigger("unhighlight", this)
    
  markRead: ->
    @$el.removeClass("unread")
    @$el.addClass("read")

    @trigger("markRead", this)

  markUnread: ->
    @$el.removeClass("read")
    @$el.addClass("unread")

    @trigger("markUnread", this)
