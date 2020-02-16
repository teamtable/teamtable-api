class CreateListMemberships < ActiveRecord::Migration[5.2]
  def change
    create_table :list_memberships do |t|
      t.belongs_to :user, index: true
      t.belongs_to :list, index: true

      t.timestamps
    end
    add_index :list_memberships, [:user_id, :list_id], unique: true
  end
end
