# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email do
    before(:create) do |email|
      email.email_account = FactoryGirl.create(:gmail_account, :user => email.user) if email.email_account.nil?
      email.email_thread = FactoryGirl.create(:email_thread, :user => email.user) if email.email_thread.nil?
    end

    user

    auto_filed false
    auto_filed_reported false
    auto_filed_folder nil

    sequence(:uid) { |n| "#{n}" }
    sequence(:message_id) { |n| "#{n}" }
    list_id 'test_list'

    seen false
    snippet 'test email snippet'

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
    subject 'Test Subject'
    
    html_part '<html>Test email text</html>'
    text_part 'Test email text'
    body_text nil

    has_calendar_attachment false
  end
end
