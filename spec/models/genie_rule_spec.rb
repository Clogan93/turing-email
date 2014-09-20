require 'rails_helper'

describe EmailRule, :type => :model do
  let!(:user) { FactoryGirl.create(:user) }

  context 'validations' do
    it 'should fail to save without a user and some criteria' do
      genie_rule = GenieRule.new
      expect(genie_rule.save).to be(false)

      genie_rule.user = user
      expect(genie_rule.save).to be(false)
      
      genie_rule.from_address = 'foo@bar.com'
      expect(genie_rule.save).to be(true)
      genie_rule.from_address = nil
      expect(genie_rule.save).to be(false)

      genie_rule.to_address = 'foo@bar.com'
      expect(genie_rule.save).to be(true)
      genie_rule.to_address = nil
      expect(genie_rule.save).to be(false)

      genie_rule.subject = 'subject'
      expect(genie_rule.save).to be(true)
      genie_rule.subject = nil
      expect(genie_rule.save).to be(false)

      genie_rule.list_id = 'list@foo.com'
      expect(genie_rule.save).to be(true)
      genie_rule.list_id = nil
      expect(genie_rule.save).to be(false)

      genie_rule.from_address = 'foo@bar.com'
      genie_rule.to_address = 'foo@bar.com'
      genie_rule.subject = 'subject'
      genie_rule.list_id = 'list@foo.com'
      expect(genie_rule.save).to be(true)
    end
  end
end
