require 'rails_helper'

describe 'api/v1/email_threads/index', :type => :view do
  it 'should render the email threads' do
    email_threads = assign(:email_threads, FactoryGirl.create_list(:email_thread, 10))

    email_threads.each do |email_thread|
      FactoryGirl.create_list(:email, 10, :email_thread => email_thread)
    end

    render

    email_threads_rendered = JSON.parse(rendered)

    email_threads.zip(email_threads_rendered).each do |email_thread, email_thread_rendered|
      validate_email_thread(email_thread, email_thread_rendered)
    end
  end
end
