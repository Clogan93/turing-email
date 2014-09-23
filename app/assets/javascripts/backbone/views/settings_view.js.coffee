class TuringEmailApp.Views.SettingsView extends Backbone.View
  template: JST["backbone/templates/settings"]

  initialize: ->
    @listenTo(@model, "change", @render)
    @listenTo(@model, "hide destroy", @remove)

  render: ->
    TuringEmailApp.showSettings()
    @$el.html(@template(@model.toJSON()))

    @setupEmailBankruptcyButton()
    @setupSwitches()
    @setupSaveButton()

    return this

  setupEmailBankruptcyButton: ->
    @$el.find("#declare_email_bankruptcy").click ->
      confirm_response = confirm("Are you sure you want to declare email bankruptcy?")
      if confirm_response
        $(@).parent().append('<br /><div class="alert alert-success" role="alert">You have successfully declared email bankruptcy!</div>')
        url = "/api/v1/users/declare_email_bankruptcy"
        $.ajax
          type: "POST"
          url: url
          error: (data) ->
            TuringEmailApp.tattletale.log(JSON.stringify(data))
            TuringEmailApp.tattletale.send()

  setupSwitches: ->
    @$el.find("#go_live_switch").bootstrapSwitch()
    @$el.find("#keyboard_shortcuts_on_off_switch").bootstrapSwitch()
    @$el.find("#preview_on_off_switch").bootstrapSwitch()
    @$el.find("#genie_on_off_switch").bootstrapSwitch()

  setupSaveButton: ->
    @$el.find("#user_settings_save_button").click =>
      genie_enabled = $("#genie_on_off_switch").parent().parent().hasClass("switch-on")
      split_pane_mode = if $("#preview_on_off_switch").parent().parent().hasClass("switch-on") then "horizontal" else "off"
      
      @model.set(genie_enabled: genie_enabled, split_pane_mode: split_pane_mode)
      @model.save(null, {patch: true})
