require 'rails_helper'

describe EmailRule, :type => :model do
  let!(:user) { FactoryGirl.create(:user) }

  context 'validations' do
    it 'should fail to save without a user' do
      genie_rule = GenieRule.new
      expect(genie_rule.save).to be(false)

      genie_rule.user = user
      expect(genie_rule.save).to be(true)
    end
  end
end
