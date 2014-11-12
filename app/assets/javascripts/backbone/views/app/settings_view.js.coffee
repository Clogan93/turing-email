class TuringEmailApp.Views.SettingsView extends Backbone.View
  template: JST["backbone/templates/app/settings"]

  className: "settings-view"

  initialize: (options) ->
    @emailRules = options.emailRules
    @brainRules = options.brainRules
    @skins = options.skins

    @listenTo(options.emailRules, "reset", @render)
    @listenTo(options.brainRules, "reset", @render)
    @listenTo(options.skins, "reset", @render)
    
    @listenTo(@model, "change", @render)
    @listenTo(@model, "destroy", @remove)

  render: ->
    selectedTabID = $(".tab-pane.active").attr("id")
    
    @$el.html(@template({
      userConfiguration: @model.toJSON(),
      emailRules: @emailRules.toJSON(),
      brainRules: @brainRules.toJSON(),
      skins: @skins.toJSON()
    }))

    @setupEmailBankruptcyButton()
    @setupUninstallAppButtons()
    @setupSwitches()
    @setupRuleCreation()
    @setupRuleDeletion()

    $("a[href=#" + selectedTabID + "]").click() if selectedTabID?

    return this

  setupEmailBankruptcyButton: ->
    @$el.find(".email-bankruptcy-button").click (event) =>
      event.preventDefault()
      
      confirm_response = confirm("Are you sure you want to declare email bankruptcy?")
      if confirm_response
        token = TuringEmailApp.showAlert("You have successfully declared email bankruptcy!", "alert-success")
        $.post "/api/v1/users/declare_email_bankruptcy"

        setTimeout (=>
          TuringEmailApp.removeAlert(token)
        ), 3000

  setupSwitches: ->
    @$el.find(".demo_mode_switch").bootstrapSwitch()
    @$el.find(".keyboard_shortcuts_switch").bootstrapSwitch()
    @$el.find(".genie-switch").bootstrapSwitch()
    @$el.find(".split-pane-switch").bootstrapSwitch()
    @$el.find(".developer_switch").bootstrapSwitch()

    @$el.find(".demo_mode_switch, .keyboard_shortcuts_switch, .genie-switch, .split-pane-switch, .developer_switch").
         on("switch-change", (event, state) =>
      @saveSettings()
    )

    @$el.find(".skin-select").change(=>
      @saveSettings(true)
    )

  setupUninstallAppButtons: ->
    @$el.find(".uninstall-app-button").click (event) =>
      appID = $(event.currentTarget).attr("data")
      @trigger("uninstallAppClicked", this, appID)

      $(event.currentTarget).parent().parent().remove()
      
  saveSettings: (refresh=false) ->
    demo_mode_enabled = @$el.find(".demo_mode_switch").parent().parent().hasClass("switch-on")
    keyboard_shortcuts_enabled = @$el.find(".keyboard_shortcuts_switch").parent().parent().hasClass("switch-on")
    genie_enabled = @$el.find(".genie-switch").parent().parent().hasClass("switch-on")
    split_pane_mode = if @$el.find(".split-pane-switch").parent().parent().hasClass("switch-on") then "horizontal" else "off"
    developer_enabled = @$el.find(".developer_switch").parent().parent().hasClass("switch-on")
    skin_uid = @$el.find(".skin-select").val()

    @model.set({
      demo_mode_enabled: demo_mode_enabled,
      genie_enabled: genie_enabled,
      split_pane_mode: split_pane_mode,
      keyboard_shortcuts_enabled: keyboard_shortcuts_enabled,
      developer_enabled: developer_enabled,
      skin_uid: skin_uid
    })

    @model.save(null, {
      patch: true
      success: (model, response) =>
        location.reload() if refresh
        token = TuringEmailApp.showAlert("You have successfully saved your settings!", "alert-success")

        setTimeout (=>
          TuringEmailApp.removeAlert(token)
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