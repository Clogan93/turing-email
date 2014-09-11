require 'rails_helper'

describe Api::V1::EmailRulesController, :type => :request do
  context 'creating rules' do
    let!(:user) { FactoryGirl.create(:user) }
    
    before { post '/api/v1/sessions', :email => user.email, :password => user.password }
    
    it 'should create a rule' do
      post '/api/v1/email_rules', :list_id => 'sales.turinginc.com', :destination_folder => 'sales'
      
      expect(response).to have_http_status(:ok)
      expect(user.email_rules.count).to eq(1)
    end
  end
  
  context 'retrieving rules' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:email_rules) { FactoryGirl.create_list(:email_rule, SpecMisc::MEDIUM_LIST_SIZE, :user => user) }
    
    before { post '/api/v1/sessions', :email => user.email, :password => user.password }
    
    it 'should return the existing rules' do
      get '/api/v1/email_rules'
      email_rules_rendered = JSON.parse(response.body)
      
      expect(email_rules_rendered.length).to eq(email_rules.length)
      email_rules.zip(email_rules_rendered).each do |email_rule, email_rule_rendered|
        validate_email_rule(email_rule, email_rule_rendered)
      end
    end
  end
  
  context 'recommended rules' do
    let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
    let!(:emails) { FactoryGirl.create_list(:email, SpecMisc::LARGE_LIST_SIZE,
                                            :email_account => gmail_account,
                                            :list_id => 'test.list.com',
                                            :auto_filed => true ) }

    before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }
    
    it 'should recommend rules' do
      get '/api/v1/email_rules/recommended_rules'
      recommended_rules = JSON.parse(response.body)
      
      expect(recommended_rules.length).to eq(1)
      expect(recommended_rules[0]['list_id']).to eq('test.list.com')
      expect(recommended_rules[0]['destination_folder']).to eq("List Emails/test.list.com")
    end
  end
end
