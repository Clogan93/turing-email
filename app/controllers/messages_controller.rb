class MessagesController < ApplicationController
  
  before_filter :load_message, only: %w(show update destroy)
  respond_to :json, :html

  def index
    @messages = Message.all

    respond_with @messages
  end

  def show
    respond_with @message
  end

  def update
    @message.update_column(:status, params[:message][:status])

    respond_with @message
  end

  def create
    @message = Message.create params[:message]

    respond_with @message
  end

  def destroy
    @message.destroy

    respond_with @message
  end

  private

  def load_message
    @message = Message.find params[:id]
  end

  def message_params
    params.require(:message).permit(:description, :status, :created_at, :updated_at)
  end

end
