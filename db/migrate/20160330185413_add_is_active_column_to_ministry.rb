class AddIsActiveColumnToMinistry < ActiveRecord::Migration
  def change
    add_column :ministries, :active, :boolean, null: false, default: false
  end
end
