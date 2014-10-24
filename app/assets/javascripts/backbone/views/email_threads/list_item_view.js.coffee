TuringEmailApp.Views.EmailThreads ||= {}

class TuringEmailApp.Views.EmailThreads.ListItemView extends Backbone.View
  template: JST["backbone/templates/email_threads/list_item"]
  tagName: "TR"

  initialize: ->
    @listenTo(@model, "change", @render)
    @listenTo(@model, "removedFromCollection destroy", @remove)

  render: ->
    checked = @isChecked()
    
    modelJSON = {}
    modelJSON["fromPreview"] = @model.fromPreview()
    modelJSON["subjectPreview"] = @model.subjectPreview()
    modelJSON["datePreview"] = @model.datePreview()
    modelJSON["snippet"] = @model.get("snippet")
    @$el.html(@template(modelJSON))

    if @model.get("seen")
      @markRead(silent: true)
    else
      @markUnread(silent: true)

    @setupClick()
    @setupCheckbox()
    
    @check(silent: true) if checked
    
    return this

  #######################
  ### Setup Functions ###
  #######################
    
  setupClick: ->
    tds = @$el.find('td.check-mail, td.mail-contact, td.mail-subject, td.mail-date')
    tds.click (event) =>
      @trigger("click", this)

  addedToDOM: ->
    @setupCheckbox()

  setupCheckbox: ->
    @$el.find(".i-checks").iCheck
      checkboxClass: "icheckbox_square-green"
      radioClass: "iradio_square-green"

    @diviCheck = @$el.find("div.icheckbox_square-green")
    
    @$el.find("div.icheckbox_square-green ins").click (event) =>
      @updateCheckStyles()

      if @isChecked()
        @trigger("checked", this)
      else
        @trigger("unchecked", this)

  ###############
  ### Getters ###
  ###############

  isSelected: ->
    return @$el.hasClass "currently_being_read"

  isChecked: ->
    return @diviCheck?.hasClass "checked"

  ###############
  ### Actions ###
  ###############

  select: (options) ->
    return if @isSelected()
    
    @$el.addClass("currently_being_read")

    @trigger("selected", this) if (not options?.silent?) || options.silent is false

  deselect: (options) ->
    return if not @isSelected()
    
    @$el.removeClass("currently_being_read")

    @trigger("deselected", this) if (not options?.silent?) || options.silent is false

  updateCheckStyles: ->
    if @diviCheck.hasClass "checked"
      @$el.addClass("checked_email_thread")
    else
      @$el.removeClass("checked_email_thread")

  toggleCheck: ->
    if @diviCheck.hasClass "checked" then @uncheck() else @check()
    
  check: (options) ->
    return if @isChecked()
    
    @diviCheck.iCheck("check")
    @updateCheckStyles()
    
    @trigger("checked", this) if (not options?.silent?) || options.silent is false

  uncheck: (options) ->
    return if not @isChecked()
    
    @diviCheck.iCheck("uncheck")
    @updateCheckStyles()
    
    @trigger("unchecked", this) if (not options?.silent?) || options.silent is false
    
  markRead: (options) ->
    @$el.removeClass("unread")
    @$el.addClass("read")

    @trigger("markRead", this) if (not options?.silent?) || options.silent is false

  markUnread: (options) ->
    @$el.removeClass("read")
    @$el.addClass("unread")

    @trigger("markUnread", this) if (not options?.silent?) || options.silent is false
