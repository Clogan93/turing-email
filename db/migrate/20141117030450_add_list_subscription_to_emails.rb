class AddListSubscriptionToEmails < ActiveRecord::Migration
  def change
    add_belongs_to :emails, :list_subscription
  end
end
