# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email_attachment do
    email
    sequence(:filename) { |n| "file_#{n}.txt" }
    content_type 'image/png'
    file_size 100
  end
end
