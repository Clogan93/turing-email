# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email_thread do
    association :email_account, :factory => :gmail_account
    user { email_account.user }
    sequence(:uid) { |n| "#{n}" }
  end
end
