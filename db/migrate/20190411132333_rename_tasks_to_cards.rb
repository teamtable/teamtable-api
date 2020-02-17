class RenameTasksToCards < ActiveRecord::Migration[5.2]
  def change
    rename_table :tasks, :cards
    rename_column :assignments, :task_id, :card_id
  end
end
