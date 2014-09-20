require 'rails_helper'

describe User, :type => :model do
  let(:user_template) { FactoryGirl.build(:user) }

  context 'validations' do
    let(:email_address) { 'FOO@bar.com' }
    
    it 'should fail to save without password and matching password confirmation' do
      user = User.new
      expect(user.save).to be(false)

      user.password = 'password'
      expect(user.save).to be(false)
      
      user.password = nil
      user.password_confirmation = 'password'
      expect(user.save).to be(false)

      user.password = user.password_confirmation = 'password'
      expect(user.save).to be(true)
    end

    it 'should cleanse the email address' do
      user = User.new
      user.password = user.password_confirmation = 'password'
      
      user.email = email_address
      expect(user.save).to be(true)
      expect(user.email).to eq(cleanse_email(email_address))
    end
  end
  
  context 'get_unique_violation_error' do
    it 'should return the email error message when the email is in use' do
      begin
        expect(user_template.save).to be(true)

        user = User.new()
        user.email = user_template.email
        user.password = user.password_confirmation = user_template.password
        expect(user.save).to be(true)

        assert false
      rescue ActiveRecord::RecordNotUnique => unique_violation
        expect(User.get_unique_violation_error(unique_violation)).to eq('Error email in use.')
      end
    end
  end

  context 'when using create_from_post' do
    let(:params) {  ActionController::Parameters.new(
                      :user => { :email => user_template.email,
                                 :password => user_template.password,
                                 :password_confirmation => user_template.password}
                      ) }

    it 'should create a user when the email and password are valid' do
      user, result = User.create_from_post(params)
      expect(result).to eq(true)
      expect(User.find_by_email(user_template.email).id).to eq(user.id)
    end

    it 'should NOT create a user when the email is invalid' do
      params[:user][:email] = 'invalid email'
      user, result = User.create_from_post(params)
      expect(result).to eq(false)
      expect(User.find_by_email(user_template.email)).to be(nil)
    end

    it 'should NOT create a user when the email is in use' do
      begin
        expect(user_template.save).to be(true)
        user, result = User.create_from_post(params)
        assert false
      rescue ActiveRecord::RecordNotUnique => unique_violation
        expect(User.get_unique_violation_error(unique_violation)).to eq('Error email in use.')
      end
    end
  end

  context 'when using api_create' do
    it 'should create a user when the email and password are valid' do
      user, result = User.api_create(user_template.email, user_template.password)
      expect(result).to eq(true)
      expect(User.find_by_email(user_template.email).id).to eq(user.id)
    end

    it 'should NOT create a user when the email is invalid' do
      user, result = User.api_create('invalid email', user_template.password)
      expect(result).to eq(false)
      expect(User.find_by_email(user_template.email)).to be(nil)
    end

    it 'should NOT create a user when the email is in use' do
      begin
        expect(user_template.save).to be(true)
        user, result = User.api_create(user_template.email, user_template.password)
        assert false
      rescue ActiveRecord::RecordNotUnique => unique_violation
        expect(User.get_unique_violation_error(unique_violation)).to eq('Error email in use.')
      end
    end
  end
  
  context 'apply_email_rules' do
    let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
    let!(:email_rule) { FactoryGirl.create(:email_rule, :user => gmail_account.user,
                                           :from_address => nil, :to_address => nil, :subject => nil) }
    
    let!(:emails) { FactoryGirl.create_list(:email, SpecMisc::SMALL_LIST_SIZE,
                                            :email_account => gmail_account,
                                            :list_id => email_rule.list_id) }
    let!(:emails_other) { FactoryGirl.create_list(:email, SpecMisc::SMALL_LIST_SIZE,
                                                  :email_account => gmail_account) }
    let!(:emails_all) { emails.dup.concat(emails_other) }
    
    let!(:gmail_label) { FactoryGirl.create(:gmail_label, :gmail_account => gmail_account,
                                            :name => email_rule.destination_folder_name) }
    
    it 'should apply the email rule to matching emails' do
      expect(gmail_label.emails.count).to eq(0)
      
      gmail_account.user.apply_email_rules(emails_all)
      
      gmail_label.reload
      expect(gmail_label.emails.count).to eq(emails.length)
    end
  end
  
  describe '#apply_email_rules_to_folder' do
    let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
    let!(:email_rule) { FactoryGirl.create(:email_rule, :user => gmail_account.user,
                                           :from_address => nil, :to_address => nil, :subject => nil) }

    let!(:emails) { FactoryGirl.create_list(:email, SpecMisc::SMALL_LIST_SIZE,
                                            :email_account => gmail_account,
                                            :list_id => email_rule.list_id) }
    let!(:emails_other) { FactoryGirl.create_list(:email, SpecMisc::SMALL_LIST_SIZE,
                                                  :email_account => gmail_account) }
    let!(:emails_all) { emails.dup.concat(emails_other) }

    let!(:gmail_label) { FactoryGirl.create(:gmail_label, :gmail_account => gmail_account,
                                            :name => email_rule.destination_folder_name) }
    
    let!(:inbox_label) { FactoryGirl.create(:gmail_label_inbox, :gmail_account => gmail_account) }
    
    before { create_email_folder_mappings(emails, inbox_label) }

    it 'should apply the email rule to emails in the inbox' do
      expect(gmail_label.emails.count).to eq(0)
      expect(inbox_label.emails.count).to eq(emails.length)

      gmail_account.user.apply_email_rules_to_folder(gmail_account.inbox_folder)

      gmail_label.reload
      inbox_label.reload
      expect(gmail_label.emails.count).to eq(emails.length)
      expect(inbox_label.emails.count).to eq(0)
    end
  end

  describe '#destroy' do
    let!(:user) { FactoryGirl.create(:user) }

    let!(:user_auth_keys) { FactoryGirl.create_list(:user_auth_key, SpecMisc::SMALL_LIST_SIZE, :user => user) }
    let!(:email_accounts) { FactoryGirl.create_list(:gmail_account, SpecMisc::SMALL_LIST_SIZE, :user => user) }
    let!(:genie_rules) { FactoryGirl.create_list(:genie_rule, SpecMisc::SMALL_LIST_SIZE, :user => user) }
    let!(:email_rules) { FactoryGirl.create_list(:email_rule, SpecMisc::SMALL_LIST_SIZE, :user => user) }

    it 'should destroy the associated models' do
      expect(UserAuthKey.where(:user => user).count).to eq(user_auth_keys.length)
      expect(GmailAccount.where(:user => user).count).to eq(email_accounts.length)
      expect(GenieRule.where(:user => user).count).to eq(genie_rules.length)
      expect(EmailRule.where(:user => user).count).to eq(email_rules.length)
      
      expect(UserConfiguration.where(:user => user).count).to eq(1)

      expect(user.destroy).not_to be(false)

      expect(UserAuthKey.where(:user => user).count).to eq(0)
      expect(GmailAccount.where(:user => user).count).to eq(0)
      expect(GenieRule.where(:user => user).count).to eq(0)
      expect(EmailRule.where(:user => user).count).to eq(0)
      
      expect(UserConfiguration.where(:user => user).count).to eq(0)
    end
  end
end
