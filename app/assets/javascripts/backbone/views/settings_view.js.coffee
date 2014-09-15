TuringEmailApp.Views.Reports ||= {}

class TuringEmailApp.Views.Reports.SettingsView extends Backbone.View
  template: JST["backbone/templates/settings"]

  initialize: ->
    return

  remove: ->
    @$el.remove()

  setup_the_declare_email_bankruptcy_button: ->
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

  setup_go_live_switch: ->
    $("#go_live_switch").bootstrapSwitch()
    $("#keyboard_shortcuts_on_off_switch").bootstrapSwitch()

  render: ->
    TuringEmailApp.reportsRouter.restyle_other_elements()

    @$el.html(@template())

    @setup_the_declare_email_bankruptcy_button()

    @setup_go_live_switch()

    return this
