# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email_thread do
    user
    sequence(:uid) { |n| "#{n}" }
  end
end
