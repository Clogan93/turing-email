require 'rails_helper'

describe Api::V1::EmailFoldersController, :type => :request do
  let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
  let!(:gmail_account_other) { FactoryGirl.create(:gmail_account) }
  let!(:email_folders) { FactoryGirl.create_list(:gmail_label, 10, :gmail_account => gmail_account) }
  let!(:email_folders_other) { FactoryGirl.create_list(:gmail_label, 10, :gmail_account => gmail_account_other) }

  def verify_email_folders_expected(email_folders_expected, email_folders_rendered)
    email_folders_expected.zip(email_folders_rendered).each do |email_folder_expected, email_folder_rendered|
      expect(email_folder_rendered['label_id']).to eq(email_folder_expected.label_id)
    end
  end

  def verify_email_folders_unexpected(email_folders_unexpected, email_folders_rendered)
    email_folder_labels_ids_rendered = []

    email_folders_rendered.each do |email_folder_rendered|
      email_folder_labels_ids_rendered << email_folder_rendered['label_id']
    end

    email_folders_unexpected.each do |email_folder_unexpected|
      expect(email_folder_labels_ids_rendered.include?(email_folder_unexpected.label_id)).to eq(false)
    end
  end

  context 'when the user is NOT logged in' do
    #let(:email_folders) { FactoryGirl.create_list(:gmail_label, 10) }

    it 'should NOT show the email folders' do
      get "/api/v1/email_folders"

      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'when the user is logged in' do
    before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

    it 'should show the email folders' do
      get "/api/v1/email_folders"

      expect(response).to have_http_status(:ok)
      expect(response).to render_template('api/v1/gmail_labels/index')

      email_folders_rendered = JSON.parse(response.body)
      verify_email_folders_expected(email_folders, email_folders_rendered)
    end

    it 'should NOT show the other email folders' do
      get "/api/v1/email_folders"

      expect(response).to have_http_status(:ok)
      expect(response).to render_template('api/v1/gmail_labels/index')

      email_folders_rendered = JSON.parse(response.body)
      verify_email_folders_unexpected(email_folders_other, email_folders_rendered)
    end
  end

  context 'when the other user is logged in' do
    before { post '/api/v1/sessions', :email => gmail_account_other.user.email, :password => gmail_account_other.user.password }

    it 'should show the other email folders' do
      get "/api/v1/email_folders"

      expect(response).to have_http_status(:ok)
      expect(response).to render_template('api/v1/gmail_labels/index')

      email_folders_rendered = JSON.parse(response.body)
      verify_email_folders_expected(email_folders_other, email_folders_rendered)
    end

    it 'should NOT show the email folders' do
      get "/api/v1/email_folders"

      expect(response).to have_http_status(:ok)
      expect(response).to render_template('api/v1/gmail_labels/index')

      email_folders_rendered = JSON.parse(response.body)
      verify_email_folders_unexpected(email_folders, email_folders_rendered)
    end
  end
end
