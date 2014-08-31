require 'rails_helper'

describe 'api/v1/email_threads/index', :type => :view do
  it 'should render the email threads' do
    email_threads = assign(:email_threads, FactoryGirl.create_list(:email_thread, 10))

    email_threads.each do |email_thread|
      email_thread.emails = FactoryGirl.create_list(:email, 10, :email_thread => email_thread)
    end

    render

    email_threads_rendered = JSON.parse(rendered)

    email_threads.zip(email_threads_rendered).each do |email_thread, email_thread_rendered|
      expected_attributes = %w(uid emails)
      expected_attributes_to_skip = %w(emails)
      spec_validate_attributes(expected_attributes, email_thread, email_thread_rendered, expected_attributes_to_skip)

      expected_attributes = %w(auto_filed
                             uid message_id list_id
                             seen snippet date
                             from_name from_address
                             sender_name sender_address
                             reply_to_name reply_to_address
                             tos ccs bccs
                             subject
                             html_part text_part body_text)

      email_thread.emails.zip(email_thread_rendered['emails']).each do |email, email_rendered|
        spec_validate_attributes(expected_attributes, email, email_rendered)
      end
    end
  end
end
