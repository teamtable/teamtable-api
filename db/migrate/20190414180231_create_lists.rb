class CreateLists < ActiveRecord::Migration[5.2]
  def change
    create_table :lists do |t|
      t.string :title
      t.text :description
      t.belongs_to :project, foreign_key: true
      t.belongs_to :created_by, foreign_key: {to_table: :users}

      t.timestamps
    end
  end
end
