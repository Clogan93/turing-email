# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_auth_key do
    user

    sequence(:encrypted_auth_key) { |n| "encrypted_auth_key #{n}" }
  end
end
