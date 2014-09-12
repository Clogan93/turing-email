# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :genie_rule do
    user

    sequence(:uid) { |n| n.to_s }
    sequence(:list_id) { |n| "sales_#{n}.turinginc.com" }
  end
end
