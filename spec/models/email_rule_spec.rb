require 'rails_helper'

describe EmailRule, :type => :model do
  let!(:user) { FactoryGirl.create(:user) }

  context 'validations' do
    it 'should fail to save without an user, uid, destination_folder_name' do
      email_rule = EmailRule.new
      expect(email_rule.save).to be(false)
  
      email_rule.user = user
      expect(email_rule.save).to be(false)
  
      email_rule.uid = '123'
      expect(email_rule.save).to be(false)
  
      email_rule.destination_folder_name = 'Test'
      expect(email_rule.save).to be(true)
    end
  end
end
