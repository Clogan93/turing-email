class TuringEmailApp.Views.SettingsView extends Backbone.View
  template: JST["backbone/templates/settings"]

  className: "settings-view"

  initialize: (options) ->
    @emailRules = options.emailRules
    @brainRules = options.brainRules

    @listenTo(options.emailRules, "reset", @render)
    @listenTo(options.brainRules, "reset", @render)
    
    @listenTo(@model, "change", @render)
    @listenTo(@model, "destroy", @remove)

  render: ->
    @$el.html(@template({'userSettings' : @model.toJSON(), 'emailRules' : @emailRules.toJSON(), 'brainRules' : @brainRules.toJSON()}))

    @setupEmailBankruptcyButton()
    @setupUninstallAppButtons()
    @setupSwitches()
    @setupRuleCreation()
    @setupRuleDeletion()

    return this

  setupEmailBankruptcyButton: ->
    @$el.find(".email-bankruptcy-button").click (event) =>
      event.preventDefault()
      
      confirm_response = confirm("Are you sure you want to declare email bankruptcy?")
      if confirm_response
        @showSettingsAlert('You have successfully declared email bankruptcy!')
        $.post "/api/v1/users/declare_email_bankruptcy"

        setTimeout (=>
          @removeSettingsAlert()
        ), 3000

  setupSwitches: ->
    @$el.find(".demo_mode_switch").bootstrapSwitch()
    @$el.find(".keyboard_shortcuts_switch").bootstrapSwitch()
    @$el.find("#genie_switch").bootstrapSwitch()
    @$el.find("#split_pane_switch").bootstrapSwitch()

    @$el.find(".demo_mode_switch, .keyboard_shortcuts_switch, #genie_switch, #split_pane_switch").on "switch-change", (event, state) =>
      @saveSettings()

  setupUninstallAppButtons: ->
    @$el.find(".uninstall-app-button").click (event) ->
      $.ajax
        url: "/api/v1/apps/uninstall/" + $(@).attr("data")
        type: "DELETE"

      $(@).parent().parent().remove()
      
  saveSettings: ->
    demo_mode_enabled = @$el.find(".demo_mode_switch").parent().parent().hasClass("switch-on")
    keyboard_shortcuts_enabled = @$el.find(".keyboard_shortcuts_switch").parent().parent().hasClass("switch-on")
    genie_enabled = @$el.find("#genie_switch").parent().parent().hasClass("switch-on")
    split_pane_mode = if @$el.find("#split_pane_switch").parent().parent().hasClass("switch-on") then "horizontal" else "off"

    @model.set(demo_mode_enabled: demo_mode_enabled, genie_enabled: genie_enabled, split_pane_mode: split_pane_mode, keyboard_shortcuts_enabled: keyboard_shortcuts_enabled)

    @model.save(null, {
      patch: true
      success: (model, response) =>
        @showSettingsAlert('You have successfully saved your settings!')

        setTimeout (=>
          @removeSettingsAlert()
        ), 3000
      }
    )

  setupRuleCreation: ->
    @createRulesView = new TuringEmailApp.Views.App.CreateRuleView(
      app: TuringEmailApp
      el: @$el.find(".create_rule_view")
    )
    @createRulesView.render()

    @$el.find(".email-rules-button").click (event) =>
      @createRulesView.show("email_rule")
      
      return false

    @$el.find(".genie-rules-button").click (event) =>
      @createRulesView.show("genie_rule")

      return false

  setupRuleDeletion: ->
    @$el.find(".email-rules-table .rule-deletion-button").click (event) ->
      $.ajax
        url: "/api/v1/email_rules/" + $(@).attr("data")
        type: "DELETE"

      $(@).parent().parent().remove()

    @$el.find(".brain-rules-table .rule-deletion-button").click (event) ->
      $.ajax
        url: "/api/v1/genie_rules/" + $(@).attr("data")
        type: "DELETE"

      $(@).parent().parent().remove()

  showSettingsAlert: (alertMessage) ->
    @removeSettingsAlert() if @currentAlertToken?

    @currentAlertToken = TuringEmailApp.showAlert(alertMessage, "alert-success")

  removeSettingsAlert: ->
    if @currentAlertToken?
      TuringEmailApp.removeAlert(@currentAlertToken)
      @currentAlertToken = null
