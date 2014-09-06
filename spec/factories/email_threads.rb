# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email_thread do
    association :email_account, :factory => :gmail_account
    sequence(:uid) { |n| "#{n}" }
  end
end
