class AddIndexesToTables < ActiveRecord::Migration
  def change
    add_index :ministries, :gr_id, unique: true
    add_index :ministries, :min_code, unique: true
    add_index :areas, :gr_id, unique: true
    add_index :areas, :code, unique: true
  end
end
