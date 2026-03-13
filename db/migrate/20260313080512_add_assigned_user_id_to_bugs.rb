class AddAssignedUserIdToBugs < ActiveRecord::Migration[7.2]
  def change
    add_column :bugs, :assigned_user_id, :integer
  end
end
