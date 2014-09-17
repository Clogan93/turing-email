TuringEmailApp.Views.Reports ||= {}

class TuringEmailApp.Views.Reports.SettingsView extends Backbone.View
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

  setupGoLiveSwitch: ->
    $("#go_live_switch").bootstrapSwitch()
    $("#keyboard_shortcuts_on_off_switch").bootstrapSwitch()
    $("#preview_on_off_switch").bootstrapSwitch()
    $("#genie_on_off_switch").bootstrapSwitch()

  setupSaveButton: ->
    $("#user_settings_save_button").click ->
      console.log "Saving user settings."

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
          console.log status
          console.log data
        ).fail (data, status) ->
          console.log status
          console.log data

  render: ->
    TuringEmailApp.reportsRouter.restyle_other_elements()

    console.log @model.toJSON()
    @$el.html(@template(@model.toJSON()))

    @setupTheDeclareEmailBankruptcyButton()

    @setupGoLiveSwitch()

    @setupSaveButton()

    return this
