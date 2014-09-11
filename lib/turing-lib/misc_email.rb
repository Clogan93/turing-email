def parse_email_string(email_string)
  mail_address = Mail::Address.new(email_string)

  return :display_name => mail_address.display_name, :address => mail_address.address
rescue Exception
  m = email_string.match(/(.*)( ?<| <?)([^<@>]+@[^<@>]+)>?/)

  if m
    display_name = m[1].strip
    email_address = m[3].strip
  else
    display_name = nil
    email_address = email_string
  end

  return { :display_name => display_name, :address => email_address }
end

# sometimes list address in the list_id is missing the @
def parse_email_list_address(email_list_address)
  m = email_list_address.match(/([^@]+)@(.+)/)

  if m
    name = m[1]
    domain = m[2]
  else
    m = email_list_address.match(/(.*)\.([^\.]+\.[^\.]+)/)

    if m
      name = m[1]
      domain = m[2]
    else
      name = email_list_address
      domain = nil
    end
  end

  return { :name => name, :domain => domain }
end

# TODO write tests
def parse_email_address_field(email_raw, field)
  emails_parsed = []

  if email_raw[field] && email_raw[field].field.class != Mail::UnstructuredField
    email_raw[field].addrs.each do |addr|
      emails_parsed << { :display_name => addr.display_name, :address => addr.address }
    end
  else
    email_field = email_raw.send(field)

    if email_field
      if email_field.class == String
        emails_parsed << parse_email_string(email_field)
      else
        email_field.each do |email_string|
          emails_parsed << parse_email_string(email_string)
        end
      end
    end
  end

  return emails_parsed
end

# TODO write tests
def parse_email_headers(raw_headers)
  unfolded_headers = raw_headers.gsub(/#{Mail::Patterns::CRLF}#{Mail::Patterns::WSP}+/, ' ').
                                 gsub(/#{Mail::Patterns::WSP}+/, ' ')
  split_headers = unfolded_headers.split(Mail::Patterns::CRLF)

  headers = []
  split_headers.each { |header| headers << Mail::Field.new(header, nil, nil) }

  return headers
end

def cleanse_email(email)
  return nil if email.nil?
  return email.strip.downcase
end
