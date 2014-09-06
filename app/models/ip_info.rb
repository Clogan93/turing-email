class IpInfo < ActiveRecord::Base
  has_many :emails
  
  def IpInfo.from_ip(ip)
    ip_info = IpInfo.find_by_ip(ip)
    
    if ip_info.nil? && (Rails.env.production? || IpInfo.count < 1000)
      begin
        ip_info = IpInfo.new()
        ip_info_json = RestClient.get("https://freegeoip.net/json/#{ip}")
        ip_info_data = JSON.parse(ip_info_json)
        
        ip_info_data.each do |key, value|
          ip_info[key] = value if ip_info.respond_to?(key)
        end
        
        ip_info.save!
      rescue ActiveRecord::RecordNotUnique
        ip_info = IpInfo.find_by_ip(ip)
      end
    end

    return ip_info
  end
end
