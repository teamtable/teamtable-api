class AddDoingToAssignments < ActiveRecord::Migration[5.2]
  def change
    add_column :assignments, :doing, :boolean, default: false
  end
end
