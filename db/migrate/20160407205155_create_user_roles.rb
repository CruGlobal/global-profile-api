class CreateUserRoles < ActiveRecord::Migration
  def change
    create_table :user_roles do |t|
      t.uuid :key_guid, null: false
      t.uuid :ministry, null: false
      t.integer :role, default: 0, null: false

      t.timestamps null: false
    end
    add_index :user_roles, [:key_guid, :ministry], unique: true
  end
end
