class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.string :description
      t.string :status

      t.timestamps
    end
  end
end
