require 'rails_helper'

describe 'api/v1/users/show', :type => :view do
  it 'should render the user' do
    user = assign(:user, FactoryGirl.create(:user))
    render
    user_rendered = JSON.parse(rendered)

    expected_attributes = %w(email)
    spec_validate_attributes(expected_attributes, user, user_rendered)
  end
end
