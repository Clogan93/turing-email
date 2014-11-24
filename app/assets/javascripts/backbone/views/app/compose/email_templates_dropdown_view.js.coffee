TuringEmailApp.Views.App ||= {}

class TuringEmailApp.Views.App.EmailTemplatesDropdownView extends TuringEmailApp.Views.CollectionView
  template: JST["backbone/templates/app/compose/email_templates_dropdown"]

  initialize: (options) ->
    super(options)
    @composeView = options.composeView

  render: ->
    @cleanUpEmailTemplateUI()
    @$el.after(@template(emailTemplates: @collection.toJSON()))

    @setupCreateEmailTemplate()
    @setupDeleteEmailTemplate()
    @setupLoadEmailTemplate()
    @setupUpdateEmailTemplate()

    return this

  cleanUpEmailTemplateUI: ->
    # Global selectors must be used because jquery dialogs are added to page's body.
    $(".email-templates").remove()
    $(".create-email-templates-dialog-form").remove()
    $(".delete-email-templates-dialog-form").remove()
    $(".update-email-templates-dialog-form").remove()

  setupCreateEmailTemplate: ->
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

            emailTemplate.save(null, {
              success: (model, response) =>
                alertToken = TuringEmailApp.showAlert("You have successfully created an email template!", "alert-success")
            
                setTimeout (=>
                  TuringEmailApp.removeAlert(alertToken)
                ), 3000

                @createEmailTemplatesDialog.dialog "close"

                @collection.fetch()
              }
            )
        },
        {
          text: "Cancel"
          "class": 'btn btn-default'
          click: =>
            @createEmailTemplatesDialog.dialog "close"
        }
      ]
    )
    @$el.parent().find(".email-templates-dropdown .create-email-template").click =>
      @createEmailTemplatesDialog.dialog("open")

  setupDeleteEmailTemplate: ->
    @deleteEmailTemplatesDialog = @$el.parent().find(".delete-email-templates-dialog-form").dialog(
      autoOpen: false
      height: 200
      width: 350
      modal: true
      dialogClass: 'delete-email-templates-dialog'
      buttons: [
        {
          text: "Delete email template"
          "class": 'btn btn-danger'
          click: =>
            index = $(".delete-email-templates-dialog-form select option").index($(".delete-email-templates-dialog-form select option:selected"))
            emailTemplate = @collection.at(index)

            emailTemplate.destroy()

            alertToken = TuringEmailApp.showAlert("You have successfully deleted an email template!", "alert-success")

            setTimeout (=>
              TuringEmailApp.removeAlert(alertToken)
            ), 3000

            @deleteEmailTemplatesDialog.dialog "close"

            @collection.fetch()
        },
        {
          text: "Cancel"
          "class": 'btn btn-default'
          click: =>
            @deleteEmailTemplatesDialog.dialog "close"
        }
      ]
    )
    @$el.parent().find(".email-templates-dropdown .delete-email-template").click =>
      @deleteEmailTemplatesDialog.dialog("open")
      console.log("delete email template")

  setupLoadEmailTemplate: ->
    console.log "#setupLoadEmailTemplate"
    @$el.parent().find(".email-templates-dropdown .load-email-template").click (event) =>
      index = @$el.parent().find(".email-templates-dropdown .load-email-template").index(event.currentTarget)
      emailTemplate = @collection.at(index)

      console.log("load email template")
      @composeView.$el.find(".compose-form iframe.cke_wysiwyg_frame.cke_reset").contents().find("body.cke_editable").prepend(emailTemplate.get("html"))

  setupUpdateEmailTemplate: ->
    @updateEmailTemplatesDialog = @$el.parent().find(".update-email-templates-dialog-form").dialog(
      autoOpen: false
      height: 200
      width: 350
      modal: true
      dialogClass: 'update-email-templates-dialog'
      buttons: [
        {
          text: "Update email template"
          "class": 'btn btn-primary'
          click: =>
            index = $(".update-email-templates-dialog-form select option").index($(".update-email-templates-dialog-form select option:selected"))
            emailTemplate = @collection.at(index)

            text = @composeView.bodyText()
            html = @composeView.bodyHtml()

            emailTemplate.set({
              text: text,
              html: html
            })

            emailTemplate.save(null, {
              patch: true
              success: (model, response) =>
                alertToken = TuringEmailApp.showAlert("You have successfully updated an email template!", "alert-success")

                setTimeout (=>
                  TuringEmailApp.removeAlert(alertToken)
                ), 3000

                @updateEmailTemplatesDialog.dialog "close"

                @collection.fetch()
              }
            )
        },
        {
          text: "Cancel"
          "class": 'btn btn-default'
          click: =>
            @updateEmailTemplatesDialog.dialog "close"
        }
      ]
    )

    @$el.parent().find(".email-templates-dropdown .update-email-template").click =>
      @updateEmailTemplatesDialog.dialog("open")
      console.log("update email template")
