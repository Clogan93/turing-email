class User < ActiveRecord::Base
  has_secure_password
  
  has_many :user_auth_keys,
           :dependent => :destroy

  has_many :gmail_accounts,
           :dependent => :destroy

  has_many :emails,
           :through => :gmail_accounts

  has_many :email_threads,
           :through => :gmail_accounts

  validates :email,
            :format     => { with: $config.email_validation_regex },
            :allow_nil => true
  
  has_many :genie_rules,
           :dependent => :destroy

  before_validation {
    self.email = cleanse_email(self.email) if self.email
  }

  after_validation {
    self.errors.messages.delete(:password_digest)
  }

  # class methods

  def User.generate_email_verification_code
    return random_string(16)
  end

  def User.get_update_params(params, include_password = false)
    permitted_params = []
    permitted_params.push(:email)
    permitted_params.push(:password, :password_confirmation) if include_password

    params.require(:user).permit(permitted_params)
  end

  def User.get_unique_violation_error(unique_violation)
    if unique_violation.message =~ /index_users_on_email/
      return 'Error email in use.'
    else
      raise unique_violation
    end
  end

  def User.create_from_post(params)
    update_params = User.get_update_params(params, true)

    @user = User.new(update_params)
    return [@user, @user.save]
  end

  def User.api_create(email, password)
    @user = User.new
    @user.email = email
    @user.password = @user.password_confirmation = password

    return [@user, @user.save]
  end
end
