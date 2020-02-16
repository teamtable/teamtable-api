class CreateAssignments < ActiveRecord::Migration[5.2]
  def change
    create_table :assignments do |t|
      t.belongs_to :user, foreign_key: true
      t.belongs_to :task, foreign_key: true

      t.timestamps
    end

    add_index :assignments, [:task_id, :user_id], unique: true
  end
end
