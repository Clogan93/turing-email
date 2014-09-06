# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ip_info do
    sequence(:ip) { |n| "76.21.112.#{n}" }
    country_code 'US'
    country_name 'United States'
    region_code 'CA'
    region_name 'California'
    city 'Atherton'
    zipcode '94027'
    latitude 37.4498
    longitude -122.2004
    metro_code '807'
    area_code '650'
  end
end
