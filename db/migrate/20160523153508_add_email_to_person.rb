class AddEmailToPerson < ActiveRecord::Migration
  def change
    drop_table :email_addresses
    add_column :people, :email, :string
  end
end
