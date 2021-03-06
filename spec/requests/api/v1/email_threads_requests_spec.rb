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
    create_email_thread_emails(email_threads_inbox, email_folder: inbox)
    create_email_thread_emails(email_threads_test, email_folder: test_folder)
    create_email_thread_emails(email_threads_misc)

    create_email_thread_emails(email_threads_inbox_other, email_folder: inbox_other)
    create_email_thread_emails(email_threads_test_other, email_folder: test_folder_other)
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

    it 'should show a thread' do
      email_thread = email_threads_test.first
      
      get "/api/v1/email_threads/show/#{email_thread.uid}"
      email_thread_rendered = JSON.parse(response.body)
      
      validate_email_thread(email_thread, email_thread_rendered)
    end
    
    it 'should NOT show other thread' do
      email_thread_other = email_threads_test_other.first
      get "/api/v1/email_threads/show/#{email_thread_other.uid}"
      
      expect(response).to have_http_status($config.http_errors[:email_thread_not_found][:status_code])
    end
    
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
  
  context 'move_to_folder' do
    let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
    let!(:gmail_label) { FactoryGirl.create(:gmail_label, :gmail_account => gmail_account) }
    let!(:gmail_label_other) { FactoryGirl.create(:gmail_label, :gmail_account => gmail_account) }
    let!(:email_threads) { FactoryGirl.create_list(:email_thread, SpecMisc::TINY_LIST_SIZE, :email_account => gmail_account) }
    let!(:email_thread_uids) { EmailThread.where(:id => email_threads).pluck(:uid) }

    before { create_email_thread_emails(email_threads, email_folder: gmail_label) }

    # TODO test move by id
    context 'when the user is signed in' do
      before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }
      
      it 'should move the email threads to the specified folder' do
        expect(gmail_label.emails.length).to eq(gmail_account.emails.length)
        expect(gmail_label_other.emails.length).to eq(0)
        
        post '/api/v1/email_threads/move_to_folder', :email_thread_uids => email_thread_uids,
                                                     :email_folder_name => gmail_label_other.name
        gmail_label_rendered = JSON.parse(response.body)
        
        gmail_label.reload
        gmail_label_other.reload
        expect(gmail_label.emails.length).to eq(0)
        expect(gmail_label_other.emails.length).to eq(gmail_account.emails.length)

        validate_gmail_label(gmail_label_other, gmail_label_rendered)
      end
    end

    context 'when the other user is signed in' do
      let!(:user_other) { FactoryGirl.create(:user) }
      before { post '/api/v1/sessions', :email => user_other.email, :password => user_other.password }

      context 'when the other user has no email account' do
        it 'should return an error' do
          post '/api/v1/email_threads/move_to_folder', :email_thread_uids => email_thread_uids,
                                                       :email_folder_name => gmail_label_other.name
          expect(response).to have_http_status($config.http_errors[:email_account_not_found][:status_code])
        end
      end
      
      context 'when the other user has an email account' do
        let!(:gmail_account_other) { FactoryGirl.create(:gmail_account, :user => user_other) }
        
        it 'should NOT move the email threads to the specified folder' do
          expect(gmail_label.emails.length).to eq(gmail_account.emails.length)
          expect(gmail_label_other.emails.length).to eq(0)
  
          post '/api/v1/email_threads/move_to_folder', :email_thread_uids => email_thread_uids,
                                                       :email_folder_name => gmail_label_other.name
  
          gmail_label.reload
          gmail_label_other.reload
          expect(gmail_label.emails.length).to eq(gmail_account.emails.length)
          expect(gmail_label_other.emails.length).to eq(0)
        end
      end
    end
  end

  context 'apply_gmail_label' do
    let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
    let!(:gmail_label) { FactoryGirl.create(:gmail_label, :gmail_account => gmail_account) }
    let!(:gmail_label_other) { FactoryGirl.create(:gmail_label, :gmail_account => gmail_account) }
    let!(:email_threads) { FactoryGirl.create_list(:email_thread, SpecMisc::TINY_LIST_SIZE, :email_account => gmail_account) }
    let!(:email_thread_uids) { EmailThread.where(:id => email_threads).pluck(:uid) }

    before { create_email_thread_emails(email_threads, email_folder: gmail_label) }

    # TODO test move by id
    context 'when the user is signed in' do
      before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

      it 'should move the email threads to the specified folder' do
        expect(gmail_label.emails.length).to eq(gmail_account.emails.length)
        expect(gmail_label_other.emails.length).to eq(0)

        post '/api/v1/email_threads/apply_gmail_label', :email_thread_uids => email_thread_uids,
                                                        :gmail_label_name => gmail_label_other.name
        gmail_label_rendered = JSON.parse(response.body)
        
        gmail_label.reload
        gmail_label_other.reload
        expect(gmail_label.emails.length).to eq(gmail_account.emails.length)
        expect(gmail_label_other.emails.length).to eq(gmail_account.emails.length)
        
        validate_gmail_label(gmail_label_other, gmail_label_rendered)
      end
    end

    context 'when the other user is signed in' do
      let!(:user_other) { FactoryGirl.create(:user) }
      before { post '/api/v1/sessions', :email => user_other.email, :password => user_other.password }

      context 'when the other user has no email account' do
        it 'should return an error' do
          post '/api/v1/email_threads/apply_gmail_label', :email_thread_uids => email_thread_uids,
                                                          :gmail_label_name => gmail_label_other.name
          expect(response).to have_http_status($config.http_errors[:email_account_not_found][:status_code])
        end
      end

      context 'when the other user has an email account' do
        let!(:gmail_account_other) { FactoryGirl.create(:gmail_account, :user => user_other) }

        it 'should NOT move the email threads to the specified folder' do
          expect(gmail_label.emails.length).to eq(gmail_account.emails.length)
          expect(gmail_label_other.emails.length).to eq(0)
  
          post '/api/v1/email_threads/apply_gmail_label', :email_thread_uids => email_thread_uids,
               :gmail_label_name => gmail_label_other.name
  
          gmail_label.reload
          gmail_label_other.reload
          expect(gmail_label.emails.length).to eq(gmail_account.emails.length)
          expect(gmail_label_other.emails.length).to eq(0)
        end
      end
    end
  end

  context 'remove_from_folder' do
    let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
    let!(:gmail_label) { FactoryGirl.create(:gmail_label, :gmail_account => gmail_account) }
    let!(:email_threads) { FactoryGirl.create_list(:email_thread, SpecMisc::TINY_LIST_SIZE, :email_account => gmail_account) }
    let!(:email_thread_uids) { EmailThread.where(:id => email_threads).pluck(:uid) }

    before { create_email_thread_emails(email_threads, email_folder: gmail_label) }

    context 'when the user is signed in' do
      before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }
      
      it 'should remove emails from the specified folder' do
        expect(gmail_label.emails.length).to eq(gmail_account.emails.length)
        
        post '/api/v1/email_threads/remove_from_folder', :email_thread_uids => email_thread_uids,
                                                         :email_folder_id => gmail_label.label_id
  
        gmail_label.reload
        expect(gmail_label.emails.length).to eq(0)
      end
    end

    context 'when the other user is signed in' do
      let!(:user_other) { FactoryGirl.create(:user) }
      before { post '/api/v1/sessions', :email => user_other.email, :password => user_other.password }

      context 'when the other user has no email account' do
        it 'should return an error' do
          post '/api/v1/email_threads/remove_from_folder', :email_thread_uids => email_thread_uids,
                                                           :email_folder_id => gmail_label.label_id
          expect(response).to have_http_status($config.http_errors[:email_account_not_found][:status_code])
        end
      end

      context 'when the other user has an email account' do
        let!(:gmail_account_other) { FactoryGirl.create(:gmail_account, :user => user_other) }

        it 'should NOT remove emails from the specified folder' do
          expect(gmail_label.emails.length).to eq(gmail_account.emails.length)
  
          post '/api/v1/email_threads/remove_from_folder', :email_thread_uids => email_thread_uids,
                                                           :email_folder_id => gmail_label.label_id
  
          gmail_label.reload
          expect(gmail_label.emails.length).to eq(gmail_account.emails.length)
        end
      end
    end
  end

  context 'trash' do
    let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
    let!(:gmail_label) { FactoryGirl.create(:gmail_label, :gmail_account => gmail_account) }
    let!(:trash_label) { FactoryGirl.create(:gmail_label_trash, :gmail_account => gmail_account) }
    let!(:email_threads) { FactoryGirl.create_list(:email_thread, SpecMisc::TINY_LIST_SIZE, :email_account => gmail_account) }
    let!(:email_thread_uids) { EmailThread.where(:id => email_threads).pluck(:uid) }
    
    before { create_email_thread_emails(email_threads, email_folder: gmail_label) }

    context 'when the user is signed in' do
      before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password} 
      
      it 'should move emails to trash' do
        expect(gmail_label.emails.length).to eq(gmail_account.emails.length)
        expect(trash_label.emails.length).to eq(0)
  
        post '/api/v1/email_threads/trash', :email_thread_uids => email_thread_uids
  
        gmail_label.reload
        trash_label.reload
  
        expect(gmail_label.emails.length).to eq(0)
        expect(trash_label.emails.length).to eq(gmail_account.emails.length)
      end
    end

    context 'when the other user is signed in' do
      let!(:user_other) { FactoryGirl.create(:user) }
      before { post '/api/v1/sessions', :email => user_other.email, :password => user_other.password }

      context 'when the other user has no email account' do
        it 'should return an error' do
          post '/api/v1/email_threads/trash', :email_thread_uids => email_thread_uids
          expect(response).to have_http_status($config.http_errors[:email_account_not_found][:status_code])
        end
      end

      context 'when the other user has an email account' do
        let!(:gmail_account_other) { FactoryGirl.create(:gmail_account, :user => user_other) }

        it 'should NOT move emails to trash' do
          expect(gmail_label.emails.length).to eq(gmail_account.emails.length)
          expect(trash_label.emails.length).to eq(0)
  
          post '/api/v1/email_threads/trash', :email_thread_uids => email_thread_uids
  
          gmail_label.reload
          trash_label.reload
  
          expect(gmail_label.emails.length).to eq(gmail_account.emails.length)
          expect(trash_label.emails.length).to eq(0)
        end
      end
    end
  end
end
