class AddTypeToNotifications < ActiveRecord::Migration[7.2]
  def change
    add_column :notifications, :type, :string
  end
end
