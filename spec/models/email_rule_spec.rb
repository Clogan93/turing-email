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
      expect(email_rule.save).to be(false)

      email_rule.from_address = 'foo@bar.com'
      expect(email_rule.save).to be(true)
      email_rule.from_address = nil
      expect(email_rule.save).to be(false)

      email_rule.to_address = 'foo@bar.com'
      expect(email_rule.save).to be(true)
      email_rule.to_address = nil
      expect(email_rule.save).to be(false)

      email_rule.subject = 'subject'
      expect(email_rule.save).to be(true)
      email_rule.subject = nil
      expect(email_rule.save).to be(false)

      email_rule.list_id = 'list@foo.com'
      expect(email_rule.save).to be(true)
      email_rule.list_id = nil
      expect(email_rule.save).to be(false)

      email_rule.from_address = 'foo@bar.com'
      email_rule.to_address = 'foo@bar.com'
      email_rule.subject = 'subject'
      email_rule.list_id = 'list@foo.com'
      expect(email_rule.save).to be(true)
    end
  end
end
