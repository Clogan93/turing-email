require 'rails_helper'

describe Api::V1::EmailThreadsController, :type => :request do
  let!(:email_account) { FactoryGirl.create(:gmail_account) }
  let!(:email_account_other) { FactoryGirl.create(:gmail_account) }

  let!(:inbox) { FactoryGirl.create(:gmail_label_inbox, :gmail_account => email_account) }
  let!(:inbox_other) { FactoryGirl.create(:gmail_label_inbox, :gmail_account => email_account_other) }

  let!(:test_folder) { FactoryGirl.create(:gmail_label, :gmail_account => email_account) }
  let!(:test_folder_other) { FactoryGirl.create(:gmail_label, :gmail_account => email_account_other) }

  let!(:email_threads_inbox) { FactoryGirl.create_list(:email_thread, SpecMisc::TINY_LIST_SIZE, :email_account => email_account) }
  let!(:email_threads_inbox_other) { FactoryGirl.create_list(:email_thread, SpecMisc::TINY_LIST_SIZE, :email_account => email_account_other) }

  let!(:email_threads_test) { FactoryGirl.create_list(:email_thread, SpecMisc::TINY_LIST_SIZE, :email_account => email_account) }
  let!(:email_threads_test_other) { FactoryGirl.create_list(:email_thread, SpecMisc::TINY_LIST_SIZE, :email_account => email_account_other) }

  let!(:email_threads_misc) { FactoryGirl.create_list(:email_thread, SpecMisc::TINY_LIST_SIZE, :email_account => email_account) }
  let!(:email_threads_misc_other) { FactoryGirl.create_list(:email_thread, SpecMisc::TINY_LIST_SIZE, :email_account => email_account_other) }

  before(:each) do
    create_email_thread_emails(email_threads_inbox, inbox)
    create_email_thread_emails(email_threads_test, test_folder)
    create_email_thread_emails(email_threads_misc)

    create_email_thread_emails(email_threads_inbox_other, inbox_other)
    create_email_thread_emails(email_threads_test_other, test_folder_other)
    create_email_thread_emails(email_threads_misc_other)
  end

  context 'when the user is NOT signed in' do
    it 'should NOT show the inbox' do
      get '/api/v1/email_threads/inbox'

      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'when the user is signed in' do
    before { post '/api/v1/sessions', :email => email_account.user.email, :password => email_account.user.password }

    it 'should show the inbox threads' do
      get '/api/v1/email_threads/inbox'

      expect(response).to have_http_status(:ok)
      expect(response).to render_template('api/v1/email_threads/index')

      email_threads_rendered = JSON.parse(response.body)

      verify_models_expected(email_threads_inbox, email_threads_rendered, 'uid')
      verify_models_unexpected(email_threads_test, email_threads_rendered, 'uid')
      verify_models_unexpected(email_threads_misc, email_threads_rendered, 'uid')
      verify_models_unexpected(email_threads_inbox_other, email_threads_rendered, 'uid')
      verify_models_unexpected(email_threads_test_other, email_threads_rendered, 'uid')
      verify_models_unexpected(email_threads_misc_other, email_threads_rendered, 'uid')
    end

    it 'should NOT show the other test folder threads' do
      get '/api/v1/email_threads/in_folder', :folder_id => test_folder_other.label_id

      expect(response).to have_http_status($config.http_errors[:email_folder_not_found][:status_code])
    end

    it 'should show the test folder threads' do
      get '/api/v1/email_threads/in_folder', :folder_id => test_folder.label_id

      expect(response).to have_http_status(:ok)
      expect(response).to render_template('api/v1/email_threads/index')

      email_threads_rendered = JSON.parse(response.body)

      verify_models_expected(email_threads_test, email_threads_rendered, 'uid')
      verify_models_unexpected(email_threads_inbox, email_threads_rendered, 'uid')
      verify_models_unexpected(email_threads_misc, email_threads_rendered, 'uid')
      verify_models_unexpected(email_threads_inbox_other, email_threads_rendered, 'uid')
      verify_models_unexpected(email_threads_test_other, email_threads_rendered, 'uid')
      verify_models_unexpected(email_threads_misc_other, email_threads_rendered, 'uid')
    end
  end

  context 'when the other user is signed in' do
    before { post '/api/v1/sessions', :email => email_account_other.user.email,
                                      :password => email_account_other.user.password }

    it 'should show the other inbox threads' do
      get '/api/v1/email_threads/inbox'

      expect(response).to have_http_status(:ok)
      expect(response).to render_template('api/v1/email_threads/index')

      email_threads_rendered = JSON.parse(response.body)

      verify_models_expected(email_threads_inbox_other, email_threads_rendered, 'uid')
      verify_models_unexpected(email_threads_inbox, email_threads_rendered, 'uid')
      verify_models_unexpected(email_threads_test, email_threads_rendered, 'uid')
      verify_models_unexpected(email_threads_misc, email_threads_rendered, 'uid')
      verify_models_unexpected(email_threads_test_other, email_threads_rendered, 'uid')
      verify_models_unexpected(email_threads_misc_other, email_threads_rendered, 'uid')
    end

    it 'should NOT show the test folder threads' do
      get '/api/v1/email_threads/in_folder', :folder_id => test_folder.label_id

      expect(response).to have_http_status($config.http_errors[:email_folder_not_found][:status_code])
    end

    it 'should show the other test folder threads' do
      get '/api/v1/email_threads/in_folder', :folder_id => test_folder_other.label_id

      expect(response).to have_http_status(:ok)
      expect(response).to render_template('api/v1/email_threads/index')

      email_threads_rendered = JSON.parse(response.body)

      verify_models_expected(email_threads_test_other, email_threads_rendered, 'uid')
      verify_models_unexpected(email_threads_inbox, email_threads_rendered, 'uid')
      verify_models_unexpected(email_threads_test, email_threads_rendered, 'uid')
      verify_models_unexpected(email_threads_misc, email_threads_rendered, 'uid')
      verify_models_unexpected(email_threads_inbox_other, email_threads_rendered, 'uid')
      verify_models_unexpected(email_threads_misc_other, email_threads_rendered, 'uid')
    end
  end
end
