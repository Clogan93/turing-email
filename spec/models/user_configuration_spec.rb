require 'rails_helper'

describe UserConfiguration, :type => :model do
  let!(:user) { FactoryGirl.create(:user) }
  before { user.user_configuration.destroy }

  context 'validations' do
    it 'should fail to save without a user' do
      user_configuration = UserConfiguration.new
      expect(user_configuration.save).to be(false)
      
      user_configuration.user = user
      expect(user_configuration.save).to be(true)
    end
  end
end