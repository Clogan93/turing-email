# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :google_o_auth2_token do
    association :google_api, :factory => :gmail_account

    sequence(:access_token) { |n| "access_token #{n}" }
    expires_in 360
    issued_at 360
    sequence(:refresh_token) { |n| "refresh_token #{n}" }

    expires_at (DateTime.now + 24.hours).rfc2822
  end
end
