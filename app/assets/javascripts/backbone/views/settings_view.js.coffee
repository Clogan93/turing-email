class TuringEmailApp.Views.SettingsView extends Backbone.View
  template: JST["backbone/templates/settings"]

  initialize: ->
    return

  remove: ->
    @$el.remove()

  setupTheDeclareEmailBankruptcyButton: ->
    $("#declare_email_bankruptcy").click ->
      confirm_response = confirm("Are you sure you want to declare email bankruptcy?")
      if confirm_response
        $(@).parent().append('<br /><div class="alert alert-success" role="alert">You have successfully declared email bankruptcy!</div>')
        url = "/api/v1/users/declare_email_bankruptcy"
        $.ajax
          type: "POST"
          url: url
          success: (data) ->
            return
          error: (data) ->
            TuringEmailApp.tattletale.log(JSON.stringify(data))
            TuringEmailApp.tattletale.send()

  setupGoLiveSwitch: ->
    $("#go_live_switch").bootstrapSwitch()
    $("#keyboard_shortcuts_on_off_switch").bootstrapSwitch()
    $("#preview_on_off_switch").bootstrapSwitch()
    $("#genie_on_off_switch").bootstrapSwitch()

  setupSaveButton: ->
    $("#user_settings_save_button").click ->

      postData = {}

      if $("#genie_on_off_switch").parent().parent().hasClass("switch-on")
        postData.genie_enabled = true
      else
        postData.genie_enabled = false

      if $("#preview_on_off_switch").parent().parent().hasClass("switch-on")
        postData.split_pane_mode = "horizontal"
      else
        postData.split_pane_mode = "off"

      $.ajax({
        url: 'api/v1/user_configurations.json'
        type: 'PATCH'
        data: postData
        dataType : 'json'
        }).done((data, status) ->
          return
        ).fail (data, status) ->
          TuringEmailApp.tattletale.log(JSON.stringify(status))
          TuringEmailApp.tattletale.log(JSON.stringify(data))
          TuringEmailApp.tattletale.send()

  render: ->
    TuringEmailApp.reportsRouter.restyle_other_elements()

    @$el.html(@template(@model.toJSON()))

    @setupTheDeclareEmailBankruptcyButton()
    @setupGoLiveSwitch()
    @setupSaveButton()

    return this
