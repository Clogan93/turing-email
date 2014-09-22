require 'rails_helper'

describe UserAuthKey, :type => :model do
  let!(:user) { FactoryGirl.create(:user) }

  context 'validations' do
    it 'should fail to save without a user' do
      user_auth_key = UserAuthKey.new
      expect(user_auth_key.save).to be(false)
      user_auth_key.user = user
      expect(user_auth_key.save).to be(true)
    end
  end
end