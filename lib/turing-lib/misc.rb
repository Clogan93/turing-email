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

def append_where_condition(where_conditions, comparison, value)
  where_conditions[0] << ' AND ' if where_conditions[0].blank?
  
  where_conditions[0] << comparison
  where_conditions[1] << value
end
