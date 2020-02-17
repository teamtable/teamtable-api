class CreateCardPositions < ActiveRecord::Migration[5.2]
  def change
    create_table :card_positions do |t|
      t.belongs_to :card, foreign_key: true
      t.belongs_to :user, foreign_key: true
      t.integer :position

      t.timestamps
    end

    add_index :card_positions, [:card_id, :user_id], unique: true
    add_index :card_positions, [:position, :user_id, :card_id], unique: true
  end
end
