require 'rails_helper'

describe EmailThread, :type => :model do
  let(:email_account) { FactoryGirl.create(:gmail_account) }
  let!(:email_threads) { FactoryGirl.create_list(:email_thread, SpecMisc::MEDIUM_LIST_SIZE, :user => email_account.user) }

  context 'get_threads_from_ids' do
    it 'should return the correct threads' do

    end
  end
end
