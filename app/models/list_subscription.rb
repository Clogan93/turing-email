class ListSubscription < ActiveRecord::Base
  serialize :list_subscribe_email
  serialize :list_unsubscribe_email
  
  belongs_to :email_account, polymorphic: true

  validates_presence_of(:email_account, :uid, :list_unsubscribe)

  before_validation { self.uid = SecureRandom.uuid() if self.uid.nil? }
  
  def ListSubscription.get_domain(list_subscription, email_raw)
    domain = nil
    
    # unsubscribe
    
    if domain.blank? && list_subscription.list_unsubscribe_link
      log_exception(false) do
        uri = URI(list_subscription.list_unsubscribe_link)
        domain = uri.host
      end
    end
    
    if domain.blank? && list_subscription.list_unsubscribe_email
      domain = list_subscription.list_unsubscribe_email[:address].split('@')[-1]
    end
    
    # ID
    
    if domain.blank? && list_subscription.list_id
      domain = list_subscription.list_id.split('@')[-1]
    end

    # subscribe
    
    if domain.blank? && list_subscription.list_subscribe_link
      log_exception(false) do
        uri = URI(list_subscription.list_subscribe_link)
        domain = uri.host
      end
    end

    if domain.blank? && list_subscription.list_subscribe_email
      domain = list_subscription.list_subscribe_email[:address].split('@')[-1]
    end
    
    # from address
    
    if domain.blank?
      froms_parsed = parse_email_address_field(email_raw, :from)

      if froms_parsed.length > 0
        from_name, from_address = froms_parsed[0][:display_name], froms_parsed[0][:address]
        domain = from_address.split('@')[-1]
      end
    end
    
    if domain
      return domain.split('.')[-2..-1].join('.')
    else
      return nil
    end
  rescue
    return nil
  end
  
  def ListSubscription.create_from_email_raw(email_account, email_raw)
    list_subscription = ListSubscription.new()
    list_subscription.email_account = email_account

    if email_raw.header['List-Unsubscribe']
      list_subscription.list_unsubscribe = email_raw.header['List-Unsubscribe'].decoded.force_utf8(true)

      subscription_info = parse_email_list_subscription_header(list_subscription.list_unsubscribe)
      list_subscription.list_unsubscribe_mailto = subscription_info[:mailto]
      list_subscription.list_unsubscribe_email = subscription_info[:email]
      list_subscription.list_unsubscribe_link = subscription_info[:link]
      
      return nil if list_subscription.list_unsubscribe_mailto.nil? &&
                    list_subscription.list_unsubscribe_email.nil? &&
                    list_subscription.list_unsubscribe_link.nil?
    else
      return nil
    end

    if email_raw.header['List-Subscribe']
      list_subscription.list_subscribe = email_raw.header['List-Subscribe'].decoded.force_utf8(true)

      subscription_info = parse_email_list_subscription_header(list_subscription.list_subscribe)
      list_subscription.list_subscribe_mailto = subscription_info[:mailto]
      list_subscription.list_subscribe_email = subscription_info[:email]
      list_subscription.list_subscribe_link = subscription_info[:link]
    end
    
    if email_raw.header['List-ID']
      list_id_header_parsed = parse_email_list_id_header(email_raw.header['List-ID'])
      
      list_subscription.list_name = list_id_header_parsed[:name]
      list_subscription.list_id = list_id_header_parsed[:id]

      if list_subscription.list_name.nil?
        list_id_parts = list_subscription.list_id.split('.')
        list_subscription.list_name = list_id_parts[0].gsub(/[_-]/,' ').split.map(&:capitalize).join(' ')
      end
    end
    
    # try from address
    
    if list_subscription.list_name.nil?
      froms_parsed = parse_email_address_field(email_raw, :from)
      
      if froms_parsed.length > 0
        from_name, from_address = froms_parsed[0][:display_name], froms_parsed[0][:address]

        if !from_name.blank?
          list_subscription.list_name = from_name
        else
          list_subscription.list_name = from_address.split('@')[0]
        end
      end
    end

    list_subscription.list_domain = ListSubscription.get_domain(list_subscription, email_raw)
    
    list_subscription = ListSubscription.find_or_create_by!(list_subscription.attributes)
    if email_raw.date &&
       (
        list_subscription.most_recent_email_date.nil? ||
        (email_raw.date > list_subscription.most_recent_email_date && email_raw.date <= DateTime.now())
       )
      list_subscription.most_recent_email_date = email_raw.date
      list_subscription.save!
    end
      
    return list_subscription
  rescue
    return nil
  end
end
