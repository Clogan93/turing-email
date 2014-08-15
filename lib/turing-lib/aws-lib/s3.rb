require 'aws'

def s3_write_files(files_info)
  s3 = AWS::S3.new
  bucket = s3.buckets[$config.s3_bucket]
  
  files_info.each do |file_info|
    object = bucket.objects[file_info[:s3_key]]
    options = {
        :content_length => file_info[:file].size,
        :acl => :public_read,
        :content_md5 => Digest::MD5.file(file_info[:file].path).base64digest,
        :content_type => file_info[:content_type]
    }
    object.write(file_info[:file], options)
  
    log_console("wrote #{file_info[:description]} to s3 #{object.public_url.to_s}")
  end
end

def s3_delete(s3_key)
  s3 = AWS::S3.new
  bucket = s3.buckets[$config.s3_bucket]

  object = bucket.objects[s3_key]
  log_exception() { object.delete }
end

def s3_get_new_key()
  return random_string($config.s3_key_length)
end
