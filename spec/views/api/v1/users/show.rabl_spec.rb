require 'rails_helper'

describe 'api/v1/users/show', :type => :view do
  it 'should render the email' do
    user = assign(:user, FactoryGirl.create(:user))

    render

    user_rendered = JSON.parse(rendered)
    expect(user_rendered['email']).to eq(user.email)
  end
end
