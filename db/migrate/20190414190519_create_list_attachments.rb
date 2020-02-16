class CreateListAttachments < ActiveRecord::Migration[5.2]
  def change
    create_table :list_attachments do |t|
      t.belongs_to :list, foreign_key: true
      t.belongs_to :tag, foreign_key: true

      t.timestamps
    end
    add_index :list_attachments, [:tag_id, :list_id], unique: true
  end
end
