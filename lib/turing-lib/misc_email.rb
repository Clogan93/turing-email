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

def parse_email_list_id_header(list_id_header)
  return { :name => nil, :id => nil } if list_id_header.nil?
  
  if list_id_header.class != String
    list_id_value = list_id_header.decoded.force_utf8(true)
  else
    list_id_value = list_id_header
  end
  
  list_id_header_parsed = parse_email_string(list_id_value)
  list_name = list_id_header_parsed[:display_name]
  list_id = list_id_header_parsed[:address]
  
  if list_id.nil?
    m = list_id_value.match(/.*<(.+)>.*/)
    if m
      list_id = m[1]
    else
      list_id = list_id_value
      list_name = nil
    end
  end

  return { :name => list_name, :id => list_id }
end

# sometimes list address in the list_id is missing the @
def get_email_list_address_from_list_id(list_id)
  m = list_id.match(/([^@]+)@(.+)/)

  if m
    name = m[1]
    domain = m[2]
  else
    m = list_id.match(/(.*)\.([^\.]+\.[^\.]+)/)

    if m
      name = m[1]
      domain = m[2]
    else
      name = list_id
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
