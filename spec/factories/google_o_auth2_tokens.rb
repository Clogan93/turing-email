# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :google_o_auth2_token do
    association :google_api, :factory => :gmail_account

    access_token 'factory'
    expires_in 360
    issued_at 360
    refresh_token 'factory'

    expires_at (DateTime.now + 24.hours).rfc2822
  end
end
