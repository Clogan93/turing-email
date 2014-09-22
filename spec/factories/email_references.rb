# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email_reference do
    email

    sequence(:references_message_id) { |n| "foo#{n}@bar.com" } 
    sequence(:position) { |n| n }
  end
end
