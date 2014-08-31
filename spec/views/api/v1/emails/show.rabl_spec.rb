require 'rails_helper'

describe 'api/v1/emails/show', :type => :view do
  it 'should render the email' do
    email = assign(:email, FactoryGirl.create(:email))
    render
    email_rendered = JSON.parse(rendered)

    expected_attributes = %w(auto_filed
                             uid message_id list_id
                             seen snippet date
                             from_name from_address
                             sender_name sender_address
                             reply_to_name reply_to_address
                             tos ccs bccs
                             subject
                             html_part text_part body_text)
    spec_validate_attributes(expected_attributes, email, email_rendered)
  end
end
