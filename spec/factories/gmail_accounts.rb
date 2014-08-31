# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :gmail_account do
    user

    sequence(:google_id) { |n| "#{n}" }
    email { user.email }
    verified_email true

    last_history_id_synced nil
  end
end
