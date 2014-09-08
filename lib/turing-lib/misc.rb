class Integer
  N_BYTES = [42].pack('i').size
  N_BITS = N_BYTES * 8
  MAX = 2 ** (N_BITS - 1) - 1
  MIN = -MAX - 1
end

class String
  def force_utf8(hard = false)
    return self if !hard && self.encoding == Encoding::UTF_8

    if self.encoding != Encoding::UTF_8
      return self.encode('utf-8', :invalid => :replace, :undef => :replace, :replace => ' ')
    else
      self.encode('utf-16', :invalid => :replace, :undef => :replace, :replace => ' ').encode('utf-8', :invalid => :replace, :undef => :replace, :replace => ' ')
    end
  end
end

class ActiveSupport::TimeWithZone
  def to_s_local(time_zone_name: $config.default_time_zone, format: '%b %d at %l:%M %p')
    return self.in_time_zone(time_zone_name).strftime(format)
  end
end

def open_force_file(url)
  file = open(url)

  if file.class == StringIO
    temp_file = Tempfile.new('turing')
    temp_file.binmode
    temp_file.write(file.read())
    file = temp_file
    file.close()
    file.open()
  end

  return file
end

def parse_email_string(email_string)
  display_name = email_address = nil
  
  if email_string =~ /.* <(.*)>?/
    display_name = email_string.match(/(.*) <(.*)>?/)[1]
    email_address = email_string.match(/(.*) <(.*)>?/)[2]
  else
    email_address = address_string
  end
  
  return { :display_name => display_name, :address => email_address }
end

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

def parse_email_headers(raw_headers)
  unfolded_headers = raw_headers.gsub(/#{Mail::Patterns::CRLF}#{Mail::Patterns::WSP}+/, ' ').gsub(/#{Mail::Patterns::WSP}+/, ' ')
  split_headers = unfolded_headers.split(Mail::Patterns::CRLF)
  
  headers = []
  split_headers.each { |header| headers << Mail::Field.new(header, nil, nil) }
  
  return headers
end

def cleanse_email(email)
  return nil if email.nil?
  return email.strip.downcase
end

def random_string(length)
  return SecureRandom.base64(length * 2).gsub(/=|\/|\+/, '')[0...length]
end

def reserve_key(object, keys = {:key => nil}, length = 256)
  attempt = 0
  total_attempts = 0

  index_regexes = []
  keys.each do |field, index|
    index_regexes << Regexp.new("index_\\w*#{index.nil? ? field.to_s : index}")
  end

  while true do
    begin
      attempt += 1
      total_attempts += 1

      keys.keys.each do |field|
        object[field] = random_string(length)
      end

      object.save!

      return
    rescue ActiveRecord::RecordNotUnique => unique_violation
      found = false
      index_regexes.each do |index_regex|
        if unique_violation.message =~ index_regex
          found = true
          break
        end
      end

      raise unique_violation if !found

      if total_attempts > 10
        log_email('Unable to reserve key!', unique_violation.log_message)
        raise unique_violation
      end

      if attempt > 4
        attempt = 0
        length += 1
      end
    end
  end
end

def retry_block(retry_attempts = 2)
  attempts = 0

  begin
    yield
  rescue Exception => ex
    attempts += 1

    if attempts < retry_attempts
      retry
    else
      raise ex
    end
  end
end
