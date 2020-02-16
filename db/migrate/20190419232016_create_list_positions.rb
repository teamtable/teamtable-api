class CreateListPositions < ActiveRecord::Migration[5.2]
  def change
    create_table :list_positions do |t|
      t.belongs_to :list, foreign_key: true
      t.belongs_to :user, foreign_key: true
      t.integer :position

      t.timestamps
    end

    add_index :list_positions, [:list_id, :user_id], unique: true
    add_index :list_positions, [:position, :user_id, :list_id], unique: true
  end
end
