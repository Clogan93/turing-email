require 'rails_helper'

describe 'Gmail emails support', :type => :feature, :js => true, :link_gmail_account => true do
  let!(:user) {  FactoryGirl.create(:user) }
  let!(:gmail_account) { user.gmail_accounts.first }
  
  it 'should sync emails' do
    gmail_account.sync_email()

    inbox_emails = [
        { 'from_name' => 'David Gobaud',
          'from_address' => 'david@turinginc.com',
          'tos' => 'turingemailtest1@gmail.com',
          'ccs' => nil,
          'subject' => 'inbox email',
          'html_part' => "<div dir=\"ltr\"><br></div>\n",
          'text_part' => '' },
    
        { 'from_name' => 'David Gobaud',
          'from_address' => 'david@turinginc.com',
          'tos' => 'turingemailtest1@gmail.com',
          'ccs' => 'turingemailtest1@turinginc.com',
          'subject' => 'cc email',
          'html_part' => "<div dir=\"ltr\"><a href=\"mailto:turingemailtest1@turinginc.com\">turingemailtest1@turinginc.com</a> should be CCed<br></div>\n",
          'text_part' => "turingemailtest1@turinginc.com should be CCed\n" }
    ]
    verify_emails_in_gmail_label(gmail_account, 'INBOX', inbox_emails)

    stanford_clubs_emails = [
        { 'from_name' => 'David Gobaud',
          'from_address' => 'dgobaud@gmail.com',
          'tos' => 'turingemailtest1@gmail.com',
          'ccs' => nil,
          'subject' => 'stanford clubs email',
          'html_part' => "<div dir=\"ltr\"><br></div>\n",
          'text_part' => ''}
    ]
    verify_emails_in_gmail_label(gmail_account, 'Label_3', stanford_clubs_emails)

    hls_classes_emails = [
        { 'from_name' => 'David Gobaud',
          'from_address' => 'dgobaud@gmail.com',
          'tos' => 'turingemailtest1@gmail.com',
          'ccs' => nil,
          'subject' => 'hls classes email',
          'html_part' => "<div dir=\"ltr\">internet &amp; society!</div>\n",
          'text_part' => "internet & society!\n" }
    ]
    verify_emails_in_gmail_label(gmail_account, 'Label_4', hls_classes_emails)
    
    sent_emails = [
        { 'from_name' => 'Turing Test',
          'from_address' => 'turingemailtest1@gmail.com',
          'tos' => 'david@turinginc.com',
          'ccs' => nil,
          'subject' => 'email to david@turinginc.com',
          'html_part' => "<div dir=\"ltr\">test send</div>\n",
          'text_part' => "test send\n" }
    ]
    verify_emails_in_gmail_label(gmail_account, 'SENT', sent_emails)

    # make sure partial sync works
    num_emails = user.emails.count
    gmail_account.sync_email()
    expect(user.emails.count).to eq(num_emails)
  end
  
  it 'should download emails' do
    email_expected = { 'from_name' => 'David Gobaud',
                       'from_address' => 'david@turinginc.com',
                       'tos' => 'turingemailtest1@gmail.com',
                       'ccs' => nil,
                       'subject' => 'inbox email',
                       'html_part' => "<div dir=\"ltr\"><br></div>\n",
                       'text_part' => '' }

    gmail_id = '1483e7904ff1e39c'

    mime_data = gmail_account.mime_data_from_gmail_id(gmail_id)
    email = Email.email_from_mime_data(mime_data)
    verify_email(email, email_expected)

    gmail_data = gmail_account.gmail_data_from_gmail_id(gmail_id)
    email = GmailAccount.email_from_gmail_data(gmail_data)
    verify_email(email, email_expected)

    email_raw = gmail_account.email_raw_from_gmail_id(gmail_id)
    email = Email.email_from_email_raw(email_raw)
    verify_email(email, email_expected)
    
    email = gmail_account.email_from_gmail_id(gmail_id)
    verify_email(email, email_expected)

    gmail_data = gmail_account.gmail_data_from_gmail_id(gmail_id)
    mime_data = GmailAccount.mime_data_from_gmail_data(gmail_data)
    email = Email.email_from_mime_data(mime_data)
    verify_email(email, email_expected)

    gmail_data = gmail_account.gmail_data_from_gmail_id(gmail_id)
    email_raw = GmailAccount.email_raw_from_gmail_data(gmail_data)
    email = Email.email_from_email_raw(email_raw)
    verify_email(email, email_expected)

    gmail_data = gmail_account.gmail_data_from_gmail_id(gmail_id)
    email = GmailAccount.email_from_gmail_data(gmail_data)
    verify_email(email, email_expected)
  end
end
