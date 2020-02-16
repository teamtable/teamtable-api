class CreateTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.text :description
      t.integer :state, default: 0
      t.integer :priority, default: 0
      t.datetime :deadline
      t.belongs_to :created_by, foreign_key: { to_table: :users }
      t.belongs_to :completed_by, foreign_key: { to_table: :users }
      t.datetime :completed_at

      t.timestamps
    end
  end
end
