class AddUniqueIndexToMemberships < ActiveRecord::Migration[5.2]
  def change
    add_index :memberships, [:user_id, :project_id], unique: true
  end
end
