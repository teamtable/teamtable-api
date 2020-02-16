class CreateProjects < ActiveRecord::Migration[5.2]
  def change
    create_table :projects do |t|
      t.string :title
      t.text :description
      t.belongs_to :created_by, foreign_key: {to_table: :users}

      t.timestamps
    end
  end
end
