require 'rails_helper'

describe GmailAccount, :type => :model do
  let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
  
  describe '#inbox' do
    let!(:inbox_label) { FactoryGirl.create(:gmail_label_inbox, :gmail_account => gmail_account) }
    
    it 'should return the inbox folder' do
      expect(gmail_account.inbox_folder.id).to eq(inbox_label.id)
    end
  end

  describe '#sent' do
    let!(:sent_label) { FactoryGirl.create(:gmail_label_sent, :gmail_account => gmail_account) }

    it 'should return the sent folder' do
      expect(gmail_account.sent_folder.id).to eq(sent_label.id)
    end
  end

  describe '#drafts' do
    let!(:drafts_label) { FactoryGirl.create(:gmail_label_drafts, :gmail_account => gmail_account) }

    it 'should return the drafts folder' do
      expect(gmail_account.drafts_folder.id).to eq(drafts_label.id)
    end
  end

  describe '#trash' do
    let!(:trash_label) { FactoryGirl.create(:gmail_label_trash, :gmail_account => gmail_account) }

    it 'should return the trash folder' do
      expect(gmail_account.trash_folder.id).to eq(trash_label.id)
    end
  end
  
  describe '#set_last_history_id_synced' do
    it 'should update last_history_id_synced' do
      gmail_account.set_last_history_id_synced('test')
      gmail_account.reload
      expect(gmail_account.last_history_id_synced).to eq('test')
    end
  end
  
  describe '#move_email_to_folder' do
    let!(:email) { FactoryGirl.create(:email, :email_account => gmail_account) }

    context 'when the email is in a folder' do
      let!(:gmail_label) { FactoryGirl.create(:gmail_label, :gmail_account => gmail_account) }
      before { gmail_label.apply_to_emails([email]) }

      it 'should FAIL if no label_id or name specified' do
        label_ids = email.gmail_labels.pluck(:label_id)
        expect(label_ids).to eq([gmail_label.label_id])

        expect(gmail_account.move_email_to_folder(email)).to be(false)

        email.reload
        label_ids = email.gmail_labels.pluck(:label_id)
        expect(label_ids).to eq([gmail_label.label_id])
      end

      it 'should updated auto_filed_folder correctly' do
        label_ids = email.gmail_labels.pluck(:label_id)
        expect(label_ids).to eq([gmail_label.label_id])
        expect(email.auto_filed_folder).to be(nil)

        expect(gmail_account.move_email_to_folder(email, folder_id: gmail_label.label_id)).to be_nil()

        email.reload
        label_ids = email.gmail_labels.pluck(:label_id)
        expect(label_ids).to eq([gmail_label.label_id])
        expect(email.auto_filed_folder).to be(nil)

        expect(gmail_account.move_email_to_folder(email, folder_id: gmail_label.label_id, set_auto_filed_folder: true)).to be_nil()

        email.reload
        label_ids = email.gmail_labels.pluck(:label_id)
        expect(label_ids).to eq([gmail_label.label_id])
        expect(email.auto_filed_folder.id).to eq(gmail_label.id)
      end
      
      context 'when the target folder exists' do
        let!(:gmail_label_other) { FactoryGirl.create(:gmail_label, :gmail_account => gmail_account) }
        
        it 'should remove the email from the existing folder and move it to the new folder by label_id' do
          label_ids = email.gmail_labels.pluck(:label_id)
          expect(label_ids).to eq([gmail_label.label_id])

          expect(gmail_account.move_email_to_folder(email, folder_id: gmail_label_other.label_id)).to be_nil()
  
          email.reload
          label_ids = email.gmail_labels.pluck(:label_id)
          expect(label_ids).to eq([gmail_label_other.label_id])
        end
  
        it 'should remove the email from the existing folder and move it to the new folder by name' do
          label_ids = email.gmail_labels.pluck(:label_id)
          expect(label_ids).to eq([gmail_label.label_id])

          expect(gmail_account.move_email_to_folder(email, folder_name: gmail_label_other.name)).to be_nil()
  
          email.reload
          label_ids = email.gmail_labels.pluck(:label_id)
          expect(label_ids).to eq([gmail_label_other.label_id])
        end

        it 'should remove the email from the existing folder and move it to the new folder by label_id and name' do
          label_ids = email.gmail_labels.pluck(:label_id)
          expect(label_ids).to eq([gmail_label.label_id])

          expect(gmail_account.move_email_to_folder(email, folder_id: gmail_label_other.label_id,
                                                    folder_name: gmail_label_other.name)).to be_nil()

          email.reload
          label_ids = email.gmail_labels.pluck(:label_id)
          expect(label_ids).to eq([gmail_label_other.label_id])
        end
      end

      context 'when the target folder does NOT exist' do
        let(:label_id) { 'LABEL ID' }
        let(:label_name) { 'LABEL NAME' }
        
        it 'should remove the email from the existing folder and move it to the new folder by label_id' do
          label_ids = email.gmail_labels.pluck(:label_id)
          expect(label_ids).to eq([gmail_label.label_id])

          expect(gmail_account.move_email_to_folder(email, folder_id: label_id)).to be_nil()

          email.reload
          label_ids = email.gmail_labels.pluck(:label_id)
          expect(label_ids).to eq([label_id])
        end

        it 'should remove the email from the existing folder and move it to the new folder by name' do
          label_ids = email.gmail_labels.pluck(:label_id)
          expect(label_ids).to eq([gmail_label.label_id])

          expect(gmail_account.move_email_to_folder(email, folder_name: label_name)).to be_nil()

          email.reload
          label_ids = email.gmail_labels.pluck(:label_id)
          expect(label_ids).not_to include(gmail_label.label_id)
          
          label_names = email.gmail_labels.pluck(:name)
          expect(label_names).to eq([label_name])
        end

        it 'should remove the email from the existing folder and move it to the new folder by label_id and name' do
          label_ids = email.gmail_labels.pluck(:label_id)
          expect(label_ids).to eq([gmail_label.label_id])

          expect(gmail_account.move_email_to_folder(email, folder_id: label_id, folder_name: label_name)).to be_nil()

          email.reload()
          label_ids = email.gmail_labels.pluck(:label_id)
          expect(label_ids).to eq([label_id])
          
          label_names = email.gmail_labels.pluck(:name)
          expect(label_names).to eq([label_name])
        end
      end
    end

    context 'when the email is NOT in a folder' do
      context 'when the target folder does NOT exist' do
        let(:label_id) { 'LABEL ID' }
        let(:label_name) { 'LABEL NAME' }
        
        it 'should move the email to the new folder by label_id' do
          expect(email.gmail_labels.length).to eq(0)
  
          expect(gmail_account.move_email_to_folder(email, folder_id: label_id)).to be_nil()
  
          email.reload
          expect(email.gmail_labels.length).to eq(1)
          expect(email.gmail_labels.first.label_id).to eq(label_id)
        end
  
        it 'should move the email to the new folder by name' do
          expect(email.gmail_labels.length).to eq(0)
  
          expect(gmail_account.move_email_to_folder(email, folder_name: label_name)).to be_nil()
  
          email.reload
          expect(email.gmail_labels.length).to eq(1)
          expect(email.gmail_labels.first.name).to eq(label_name)
        end
  
        it 'should move the email to the new folder by label_id and name' do
          expect(email.gmail_labels.length).to eq(0)
  
          expect(gmail_account.move_email_to_folder(email, folder_id: label_id, folder_name: label_name)).to be_nil()
  
          email.reload()
          expect(email.gmail_labels.length).to eq(1)
          expect(email.gmail_labels.first.label_id).to eq(label_id)
          expect(email.gmail_labels.first.name).to eq(label_name)
        end
      end
    end
  end
  
  context 'apply_label_to_email' do
    let!(:email) { FactoryGirl.create(:email, :email_account => gmail_account) }

    it 'fails when no label ID or name is specified' do
      expect(email.gmail_labels.length).to eq(0)

      expect(gmail_account.apply_label_to_email(email)).to be_nil()

      email.reload
      expect(email.gmail_labels.length).to eq(0)
    end
    
    context 'when the destination label does exist' do
      let(:gmail_label) { FactoryGirl.create(:gmail_label, :gmail_account => gmail_account) }

      it 'should apply the label to the email by label_id' do
        expect(email.gmail_labels.length).to eq(0)

        expect(gmail_account.apply_label_to_email(email, label_id: gmail_label.label_id)).not_to be_nil()

        email.reload
        expect(email.gmail_labels.length).to eq(1)
        expect(email.gmail_labels.first.id).to eq(gmail_label.id)
      end

      it 'should apply the label to the email by name' do
        expect(email.gmail_labels.length).to eq(0)

        expect(gmail_account.apply_label_to_email(email, label_name: gmail_label.name)).not_to be_nil()

        email.reload
        expect(email.gmail_labels.length).to eq(1)
        expect(email.gmail_labels.first.id).to eq(gmail_label.id)
      end

      it 'should apply the label to the email by label_id and name' do
        expect(email.gmail_labels.length).to eq(0)

        expect(gmail_account.apply_label_to_email(email, label_id: gmail_label.label_id, label_name: gmail_label.name)).not_to be_nil()

        email.reload
        expect(email.gmail_labels.length).to eq(1)
        expect(email.gmail_labels.first.id).to eq(gmail_label.id)
      end
    end
    
    context 'when the destination label does NOT exist' do
      let(:label_id) { 'LABEL ID' }
      let(:label_name) { 'LABEL NAME' }

      it 'should apply the label to the email by label_id' do
        expect(email.gmail_labels.length).to eq(0)

        expect(gmail_account.apply_label_to_email(email, label_id: label_id)).not_to be_nil()

        email.reload
        expect(email.gmail_labels.length).to eq(1)
        expect(email.gmail_labels.first.label_id).to eq(label_id)
      end

      it 'should apply the label to the email by name' do
        expect(email.gmail_labels.length).to eq(0)

        expect(gmail_account.apply_label_to_email(email, label_name: label_name)).not_to be_nil()

        email.reload
        expect(email.gmail_labels.length).to eq(1)
        expect(email.gmail_labels.first.name).to eq(label_name)
      end

      it 'should apply the label to the email by label_id and name' do
        expect(email.gmail_labels.length).to eq(0)

        expect(gmail_account.apply_label_to_email(email, label_id: label_id, label_name: label_name)).not_to be_nil()

        email.reload
        expect(email.gmail_labels.length).to eq(1)
        expect(email.gmail_labels.first.label_id).to eq(label_id)
        expect(email.gmail_labels.first.name).to eq(label_name)
      end
    end
  end
  
  describe '#destroy' do
    let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
    
    let!(:email_threads) { FactoryGirl.create_list(:email_thread, SpecMisc::TINY_LIST_SIZE, :email_account => gmail_account) }
    let!(:people) { FactoryGirl.create_list(:person, SpecMisc::TINY_LIST_SIZE, :email_account => gmail_account) }
    let!(:gmail_labels) { FactoryGirl.create_list(:gmail_label, SpecMisc::TINY_LIST_SIZE, :gmail_account => gmail_account) }
    let!(:sync_failed_emails) { FactoryGirl.create_list(:sync_failed_email, SpecMisc::TINY_LIST_SIZE, :email_account => gmail_account) }
    
    before { create_email_thread_emails(email_threads) }

    it 'should destroy the associated models' do
      expect(GoogleOAuth2Token.where(:google_api => gmail_account).count).to eq(1)
      expect(EmailThread.where(:email_account => gmail_account).count).to eq(email_threads.length)
      expect(Person.where(:email_account => gmail_account).count).to eq(people.length)
      expect(GmailLabel.where(:gmail_account => gmail_account).count).to eq(gmail_labels.length)
      expect(SyncFailedEmail.where(:email_account => gmail_account).count).to eq(sync_failed_emails.length)
      expect(Email.where(:email_account => gmail_account).count).to eq(email_threads.length * SpecMisc::TINY_LIST_SIZE)

      expect(gmail_account.destroy).not_to eq(false)

      expect(GoogleOAuth2Token.where(:google_api => gmail_account).count).to eq(0)
      expect(EmailThread.where(:email_account => gmail_account).count).to eq(0)
      expect(Person.where(:email_account => gmail_account).count).to eq(0)
      expect(GmailLabel.where(:gmail_account => gmail_account).count).to eq(0)
      expect(SyncFailedEmail.where(:email_account => gmail_account).count).to eq(0)
      expect(Email.where(:email_account => gmail_account).count).to eq(0)
    end
  end
end