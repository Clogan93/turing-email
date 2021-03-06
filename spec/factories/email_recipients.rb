# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email_recipient do
    email
    person

    recipient_type EmailRecipient.recipient_types[:to]
  end
end
