require 'rails_helper'

describe IpInfo, :type => :model do
  it 'should geolocate an IP' do
    ip = '76.21.112.131'
    ip_info = IpInfo.from_ip(ip)
    
    expect(ip_info.ip).to eq('76.21.112.131')
    expect(ip_info.country_code).to eq('US')
    expect(ip_info.country_name).to eq('United States')
    expect(ip_info.region_code).to eq('CA')
    expect(ip_info.region_name).to eq('California')
    expect(ip_info.city).to eq('Atherton')
    expect(ip_info.zipcode).to eq('94027')
    expect(ip_info.latitude).to eq(37.4498)
    expect(ip_info.longitude).to eq(-122.2004)
    expect(ip_info.metro_code).to eq('807')
    expect(ip_info.area_code).to eq('650')
  end
end
