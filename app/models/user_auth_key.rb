class UserAuthKey < ActiveRecord::Base
  belongs_to :user

  validates_presence_of(:user, :encrypted_auth_key)

  before_validation {
    self.encrypted_auth_key = UserAuthKey.encrypt(UserAuthKey.new_key) if self.encrypted_auth_key.nil?
  }

  def UserAuthKey.encrypt(data)
    return Digest::SHA1.hexdigest(data)
  end

  def UserAuthKey.new_key
    return SecureRandom.urlsafe_base64
  end
end
