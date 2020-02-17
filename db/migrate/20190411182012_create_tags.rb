class CreateTags < ActiveRecord::Migration[5.2]
  def change
    create_table :tags do |t|
      t.string :name
      t.string :color
      t.belongs_to :project, foreign_key: true

      t.timestamps
    end

    add_index :tags, [:project_id, :name], unique: true
  end
end
