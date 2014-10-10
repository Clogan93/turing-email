class TuringEmailApp.Views.SettingsView extends Backbone.View
  template: JST["backbone/templates/settings"]

  initialize: ->
    @listenTo(@model, "change", @render)
    @listenTo(@model, "destroy", @remove)

  render: ->
    @$el.html(@template(@model.toJSON()))

    @setupEmailBankruptcyButton()
    @setupSwitches()
    @setupSaveButton()
    @setupEmailRulesButton()

    return this

  setupEmailBankruptcyButton: ->
    @$el.find("#email_bankruptcy_button").click (event) =>
      event.preventDefault()
      
      confirm_response = confirm("Are you sure you want to declare email bankruptcy?")
      if confirm_response
        @showSettingsAlert('You have successfully declared email bankruptcy!')
        $.post "/api/v1/users/declare_email_bankruptcy"

        setTimeout (=>
          @removeSettingsAlert()
        ), 3000

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
        success: (model, response) =>
          @showSettingsAlert('You have successfully saved your settings!')

          setTimeout (=>
            @removeSettingsAlert()
          ), 3000
        }
      )

  setupEmailRulesButton: ->
    @$el.find("#email_rules_button").click (event) =>
      $("#email-rule-dropdown a").trigger('click.bs.dropdown')
      return false

  showSettingsAlert: (alertMessage) ->
    console.log "SettingsView showSettingsAlert"

    @removeSettingsAlert() if @currentAlertToken?

    @currentAlertToken = TuringEmailApp.showAlert(alertMessage, "alert-success")

  removeSettingsAlert: ->
    console.log "SettingsView REMOVE SettingsAlert"

    if @currentAlertToken?
      TuringEmailApp.removeAlert(@currentAlertToken)
      @currentAlertToken = null
