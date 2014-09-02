# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email do
    before(:create) do |email|
      if email.user.nil?
        if email.email_account
          email.user = FactoryGirl.create(:user)
        else
          email.user = email.email_account.user
        end
      end

      email.email_account = FactoryGirl.create(:gmail_account, :user => email.user) if email.email_account.nil?
      email.email_thread = FactoryGirl.create(:email_thread, :user => email.user) if email.email_thread.nil?
    end

    auto_filed false
    auto_filed_reported false
    auto_filed_folder nil

    sequence(:uid) { |n| "#{n}" }
    sequence(:message_id) { |n| "#{n}" }
    list_id 'test_list'

    seen false
    sequence(:snippet) { |n| "test email #{n} snippet" }

    date DateTime.now.rfc2822

    from_name 'From Name'
    from_address 'from@address.com'

    sender_name 'Sender Name'
    sender_address 'sender@address.com'

    reply_to_name 'Reply To Name'
    reply_to_address 'reply_to@address.com'
    
    tos 'to@turinginc.com'
    ccs 'ccs@turinginc.com'
    bccs 'bccs@turinginc.com'
    sequence(:subject) { |n| "Test Subject #{n}" }
    
    html_part '<html>Test email text</html>'
    text_part 'Test email text'
    body_text nil

    has_calendar_attachment false
  end

  factory :seen_email, :parent => :email do
    seen true
  end
end
