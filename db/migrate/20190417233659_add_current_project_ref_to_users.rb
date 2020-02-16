class AddCurrentProjectRefToUsers < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :current_project, foreign_key: {to_table: :projects}, optional: true
  end
end
