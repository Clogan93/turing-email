require 'rails_helper'

describe 'Gmail emails support', :type => :feature, :js => true, :link_gmail_account => true do
  let!(:user) {  FactoryGirl.create(:user) }
  let!(:gmail_account) { user.gmail_accounts.first }
  
  it 'should sync the emails' do
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
  end
end
