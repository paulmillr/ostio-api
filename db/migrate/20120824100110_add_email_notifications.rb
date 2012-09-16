class AddEmailNotifications < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.boolean :enabled_email_notifications, default: false
    end
  end
end
