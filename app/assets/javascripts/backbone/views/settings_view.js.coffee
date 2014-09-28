class TuringEmailApp.Views.SettingsView extends Backbone.View
  template: JST["backbone/templates/settings"]

  initialize: ->
    @listenTo(@model, "change", @render)
    @listenTo(@model, "hide destroy", @remove)

  render: ->
    @$el.html(@template(@model.toJSON()))

    @setupEmailBankruptcyButton()
    @setupSwitches()
    @setupSaveButton()

    TuringEmailApp.showSettings()
    return this

  setupEmailBankruptcyButton: ->
    @$el.find("#email_bankruptcy_button").click (event) ->
      event.preventDefault()
      
      confirm_response = confirm("Are you sure you want to declare email bankruptcy?")
      if confirm_response
        $(@).parent().append('<br /><div class="alert alert-success" role="alert">You have successfully declared email bankruptcy!</div>')
        $.post "/api/v1/users/declare_email_bankruptcy"

  setupSwitches: ->
    @$el.find("#keyboard_shortcuts_switch").bootstrapSwitch()
    @$el.find("#split_pane_switch").bootstrapSwitch()
    @$el.find("#genie_switch").bootstrapSwitch()

  setupSaveButton: ->
    @$el.find("#user_settings_save_button").click (event) =>
      event.preventDefault()
      
      genie_enabled = $("#genie_switch").parent().parent().hasClass("switch-on")
      split_pane_mode = if $("#split_pane_switch").parent().parent().hasClass("switch-on") then "horizontal" else "off"
      
      @model.set(genie_enabled: genie_enabled, split_pane_mode: split_pane_mode)
      @model.save(null, {
        patch: true
        success: (model, response) ->
          mailBody = $("#mailBody").prepend('<div class="alert alert-success settingsSaveAlert" role="alert">You have successfully saved your settings!</div>')
          saveAlert = mailBody.children()[0]

          setTimeout (=>
            $(saveAlert).remove()
          ), 3000
        }
      )
