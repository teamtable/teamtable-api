class AddListRefToCards < ActiveRecord::Migration[5.2]
  def change
    add_reference :cards, :list, foreign_key: true
  end
end
