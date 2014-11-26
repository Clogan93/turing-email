class Api::V1::EmailAttachmentsController < ApiController
  before_action do
    signed_in_user(true)
  end

  before_action :correct_email_account

  swagger_controller :email_attachments, 'Email Attachments Controller'

  swagger_api :download do
    summary 'Download attachment.'

    param :path, :attachment_uid, :string, :required, 'Attachment UID'

    response :ok
  end

  def download
    email_attachment = @email_account.email_attachments.find_by_uid(params[:attachment_uid])
    if email_attachment.nil?
      render :status => $config.http_errors[:email_attachment_not_found][:status_code],
             :json => $config.http_errors[:email_attachment_not_found][:description]
      return
    end
    
    email = email_attachment.email
    
    if !email.attachments_uploaded
      job = Delayed::Job.find_by(:id => email.upload_attachments_delayed_job_id, :failed_at => nil)

      if job.nil?
        job = email.delay.upload_attachments()
        email.upload_attachments_delayed_job_id = job.id
        email.save!()
      end

      render :status => $config.http_errors[:email_attachment_not_ready][:status_code],
             :json => $config.http_errors[:email_attachment_not_ready][:description]
    else
      render :json => {:url => s3_url(email_attachment.s3_key)}
    end
  end
end
