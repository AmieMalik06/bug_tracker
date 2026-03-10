class CreateBugs < ActiveRecord::Migration[7.2]
  def change
    create_table :bugs do |t|
      t.string :title
      t.text :description
      t.datetime :deadline
      t.integer :bug_type
      t.integer :status
      t.references :project, null: false, foreign_key: true
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.string :screenshot

      t.timestamps
    end
  end
end
