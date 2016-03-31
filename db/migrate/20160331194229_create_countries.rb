class CreateCountries < ActiveRecord::Migration
  def change
    create_table :countries do |t|
      t.string :iso_code
      t.string :name

      t.timestamps null: false
    end

    add_index :countries, :iso_code, unique: true
  end
end
