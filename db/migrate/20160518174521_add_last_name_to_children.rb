class AddLastNameToChildren < ActiveRecord::Migration
  def change
    add_column :children, :last_name, :string
  end
end
