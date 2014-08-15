class Integer
  N_BYTES = [42].pack('i').size
  N_BITS = N_BYTES * 8
  MAX = 2 ** (N_BITS - 1) - 1
  MIN = -MAX - 1
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
