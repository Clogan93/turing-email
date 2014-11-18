TuringEmailApp.Views.App ||= {}

class TuringEmailApp.Views.App.EmailTemplatesDropdownView extends Backbone.View
  template: JST["backbone/templates/app/compose/email_templates_dropdown"]

  initialize: (options) ->
    @composeView = options.composeView

  render: ->
    @$el.append(@template())

    @$el.find(".email-templates-dropdown li").click =>
      @composeView.$el.find(".compose-form iframe.cke_wysiwyg_frame.cke_reset").contents().find("body.cke_editable").prepend("Hi [Prospect],<br /><br />
      I really enjoyed our phone conversation [or meeting] earlier today and especially liked learning about your unique role at [company]. I understand the challenges you are facing with [challenges discussed] and the impact they are having on [insert personal impact].<br /><br />
      As promised, I have attached [or linked to] the resources and materials that can help you better understand how we can help you solve [insert compelling reason to buy].<br /><br />
      Please let me know if you have any questions. Otherwise, I look forward to talking with you again on [date and time].<br /><br />
      [Signature line]<br /><br />
      [Salesperson]
      ")

    return this
