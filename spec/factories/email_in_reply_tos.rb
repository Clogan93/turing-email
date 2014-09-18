# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email_in_reply_to do
    email

    sequence(:in_reply_to_message_id) { |n| "#{n}@turinginc.com" }
    sequence(:position) { |n| n }
  end
end
