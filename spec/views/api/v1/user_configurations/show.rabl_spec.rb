require 'rails_helper'

describe 'api/v1/user_configurations/show', :type => :view do
  let(:user) { FactoryGirl.create(:user) }
  
  it 'should render the user configuration' do
    user_configuration = assign(:user_configuration, user.user_configuration)

    render

    user_configuration_rendered = JSON.parse(rendered)

    expected_attributes = %w(genie_enabled split_pane_mode)
    spec_validate_attributes(expected_attributes, user_configuration, user_configuration_rendered)
  end
end
