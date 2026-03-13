class CreateActivityNotificationTables < ActiveRecord::Migration[7.0]
  def change
    create_table :activity_notification_activities do |t|
      t.string :key
      t.string :type
      t.references :owner, polymorphic: true, index: true
      t.references :notifiable, polymorphic: true, index: true
      t.references :target, polymorphic: true, index: true
      t.boolean :read, default: false
      t.timestamps
    end

    create_table :activity_notification_targets do |t|
      t.references :target, polymorphic: true, index: true
      t.timestamps
    end
  end
end
