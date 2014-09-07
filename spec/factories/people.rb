# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :person do
    sequence(:name) { |n| "Person #{n}" }
    sequence(:email_address) { |n| "foo#{n}@bar.com" }

    association :email_account, :factory => :gmail_account
  end
end
