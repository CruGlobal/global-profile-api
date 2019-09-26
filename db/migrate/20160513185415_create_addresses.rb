class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.uuid :gr_id
      t.references :person, index: true, foreign_key: {on_delete: :cascade, on_update: :cascade}
      t.boolean :current_address
      t.string :line1
      t.string :line2
      t.string :line3
      t.string :city
      t.string :state
      t.string :country
      t.string :postal_code

      t.timestamps null: false
    end
  end
end
