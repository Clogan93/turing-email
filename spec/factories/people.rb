# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :person do
    association :email_account, :factory => :gmail_account
    
    sequence(:name) { |n| "Person #{n}" }
    sequence(:email_address) { |n| "foo#{n}@bar.com" }
  end
end
