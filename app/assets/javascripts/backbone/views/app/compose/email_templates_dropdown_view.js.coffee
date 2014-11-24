TuringEmailApp.Views.App ||= {}

class TuringEmailApp.Views.App.EmailTemplatesDropdownView extends TuringEmailApp.Views.CollectionView
  template: JST["backbone/templates/app/compose/email_templates_dropdown"]

  initialize: (options) ->
    super(options)
    @composeView = options.composeView

  render: ->
    $(".email-templates").remove()
    $(".create-email-templates-dialog-form").remove()
    @$el.after(@template(emailTemplates: @collection.toJSON()))

    @createEmailTemplatesDialog = @$el.parent().find(".create-email-templates-dialog-form").dialog(
      autoOpen: false
      height: 200
      width: 350
      modal: true
      dialogClass: 'create-email-templates-dialog'
      buttons: [
        {
          text: "Create email template"
          "class": 'btn btn-primary'
          click: =>
            emailTemplate = new TuringEmailApp.Models.EmailTemplate()
            name = $(".create-email-templates-dialog-form .email-template-name").val()
            text = @composeView.bodyText()
            html = @composeView.bodyHtml()

            emailTemplate.set({
              name: name,
              text: text,
              html: html
            })

            emailTemplate.save()

            alertToken = TuringEmailApp.showAlert("You have successfully created an email template!", "alert-success")
        
            setTimeout (=>
              TuringEmailApp.removeAlert(alertToken)
            ), 3000

            @createEmailTemplatesDialog.dialog "close"

            @collection.fetch()
        },
        {
          text: "Cancel"
          "class": 'btn btn-default'
          click: =>
            @createEmailTemplatesDialog.dialog "close"
        }
      ]
    )

    @setupCreateEmailTemplate()
    @setupLoadEmailTemplate()

    return this

  setupCreateEmailTemplate: ->
    console.log "#setupCreateEmailTemplate"
    console.log @$el.parent().find(".email-templates-dropdown li.create-email-template")
    @$el.parent().find(".email-templates-dropdown .create-email-template").click =>
      console.log("create email template")
      @createEmailTemplatesDialog.dialog("open")

  setupDeleteEmailTemplate: ->
    @$el.parent().find(".email-templates-dropdown .delete-email-template").click =>
      console.log("delete email template")

  setupLoadEmailTemplate: ->
    console.log "#setupLoadEmailTemplate"
    @$el.parent().find(".email-templates-dropdown .load-email-template").click (event) =>
      index = @$el.parent().find(".email-templates-dropdown .load-email-template").index(event.currentTarget)
      emailTemplate = @collection.at(index)

      console.log("load email template")
      @composeView.$el.find(".compose-form iframe.cke_wysiwyg_frame.cke_reset").contents().find("body.cke_editable").prepend(emailTemplate.get("html"))

  setupUpdateEmailTemplate: ->
    @$el.parent().find(".email-templates-dropdown .update-email-template").click =>
      console.log("save email template")
