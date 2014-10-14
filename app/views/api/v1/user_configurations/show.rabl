object @user_configuration

node(:id) do |user_configuration|
  "id"
end

attributes :demo_mode_enabled, :genie_enabled, :split_pane_mode, :keyboard_shortcuts_enabled
