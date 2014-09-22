class GenieRule < ActiveRecord::Base
  belongs_to :user

  validate :presence_of_rule_criteria
  validates_presence_of(:user, :uid)
  
  before_validation { self.uid = SecureRandom.uuid() if self.uid.nil? }

  def presence_of_rule_criteria
    if from_address.blank? && to_address.blank? && subject.blank? && list_id.blank?
      errors[:base] << 'This genie rule is invalid because no criteria was specified.'
    end
  end
end
