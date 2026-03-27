class CreateNotifications < ActiveRecord::Migration[7.2]
  def change
    create_table :notifications do |t|
      t.references :recipient, polymorphic: true, index: true  # who receives the notification
      t.string :key                                         # event key (e.g., :bug_assigned)
      t.jsonb :params                                       # optional extra params
      t.references :target, polymorphic: true, index: true # what the notification is about (bug)
      t.datetime :read_at                                   # mark as read
      t.timestamps
    end
  end
end
